import CustomDump
import GRDB
import XCTest
import XXDatabase
import XXModels
@testable import XXLegacyDatabaseMigrator

final class MigrateMessageTests: XCTestCase {
  var migrate: MigrateMessage!
  var newDb: XXModels.Database!

  override func setUp() async throws {
    migrate = .live
    newDb = try .inMemory()
  }

  override func tearDown() async throws {
    migrate = nil
    newDb = nil
  }

  func testMigratingDirectMessages() throws {
    let contact1 = try newDb.saveContact(.stub(1))
    let contact2 = try newDb.saveContact(.stub(2))

    let legacyMessages: [XXLegacyDatabaseMigrator.Message] = [
      .stub(1, from: contact1.id, to: contact2.id, status: .read),
      .stub(2, from: contact2.id, to: contact1.id, status: .sent),
      .stub(3, from: contact2.id, to: contact1.id, status: .sending),
      .stub(4, from: contact2.id, to: contact1.id, status: .sendingAttachment),
      .stub(5, from: contact1.id, to: contact2.id, status: .receivingAttachment),
      .stub(6, from: contact1.id, to: contact2.id, status: .received, unread: true),
      .stub(7, from: contact2.id, to: contact1.id, status: .failedToSend),
      .stub(8, from: contact2.id, to: contact1.id, status: .timedOut),
    ]

    try legacyMessages.forEach { message in
      try migrate(message, to: newDb)
    }

    let newMessages: [XXModels.Message] = try newDb.fetchMessages(.init())
      .map { $0.withNilId() }

    XCTAssertNoDifference(newMessages, [
      .stub(1, from: contact1.id, to: contact2.id, status: .received),
      .stub(2, from: contact2.id, to: contact1.id, status: .sent),
      .stub(3, from: contact2.id, to: contact1.id, status: .sending),
      .stub(4, from: contact2.id, to: contact1.id, status: .sending),
      .stub(5, from: contact1.id, to: contact2.id, status: .receiving),
      .stub(6, from: contact1.id, to: contact2.id, status: .received, isUnread: true),
      .stub(7, from: contact2.id, to: contact1.id, status: .sendingFailed),
      .stub(8, from: contact2.id, to: contact1.id, status: .sendingTimedOut),
    ])
  }

  func testMigratingGroupMessages() throws {
    let contact1 = try newDb.saveContact(.stub(1))
    let contact2 = try newDb.saveContact(.stub(2))
    let contact3 = try newDb.saveContact(.stub(3))
    let group1 = try newDb.saveGroup(.stub(1, leaderId: contact1.id))
    let group2 = try newDb.saveGroup(.stub(2, leaderId: contact2.id))

    let legacyGroupMessages: [XXLegacyDatabaseMigrator.GroupMessage] = [
      .stub(1, from: contact1.id, toGroup: group1.id, status: .sent),
      .stub(2, from: contact2.id, toGroup: group1.id, status: .read),
      .stub(3, from: contact3.id, toGroup: group1.id, status: .failed),
      .stub(4, from: contact1.id, toGroup: group2.id, status: .sending),
      .stub(5, from: contact2.id, toGroup: group2.id, status: .received, unread: true),
    ]

    try legacyGroupMessages.forEach { groupMessage in
      try migrate(groupMessage, to: newDb)
    }

    let newMessages: [XXModels.Message] = try newDb.fetchMessages(.init())
      .map { $0.withNilId() }

    XCTAssertNoDifference(newMessages, [
      .stub(1, from: contact1.id, toGroup: group1.id, status: .sent),
      .stub(2, from: contact2.id, toGroup: group1.id, status: .received),
      .stub(3, from: contact3.id, toGroup: group1.id, status: .sendingFailed),
      .stub(4, from: contact1.id, toGroup: group2.id, status: .sending),
      .stub(5, from: contact2.id, toGroup: group2.id, status: .received, isUnread: true),
    ])
  }

  func testMigratingReplyToUnknownMessage() throws {
    var legacyMessage = XXLegacyDatabaseMigrator.Message.stub(1)
    legacyMessage.payload.reply = .init(
      messageId: "unknown-message-id".data(using: .utf8)!,
      senderId: "unknown-contact-id".data(using: .utf8)!
    )

    XCTAssertThrowsError(try migrate(legacyMessage, to: newDb)) { error in
      XCTAssertEqual(
        error as? MigrateMessage.ReplyMessageNotFound,
        MigrateMessage.ReplyMessageNotFound()
      )
    }
  }

  func testMigratingMessageWithUnknownSenderAndRecipient() throws {
    let senderId = "sender-id".data(using: .utf8)!
    let recipientId = "recipient-id".data(using: .utf8)!

    let legacyMessage = XXLegacyDatabaseMigrator.Message.stub(
      1,
      from: senderId,
      to: recipientId,
      status: .received
    )

    try migrate(legacyMessage, to: newDb)

    let newMessages: [XXModels.Message] = try newDb.fetchMessages(.init())
      .map { $0.withNilId() }

    XCTAssertNoDifference(newMessages, [
      .stub(1, from: senderId, to: recipientId, status: .received)
    ])

    XCTAssertNoDifference(try newDb.fetchContacts(.init()), [
      .init(id: senderId, createdAt: Date(nsSince1970: legacyMessage.timestamp)),
      .init(id: recipientId, createdAt: Date(nsSince1970: legacyMessage.timestamp)),
    ])
  }

  func testMigratingMessageWithUnknownGroup() throws {
    let sender = try newDb.saveContact(.stub(1))

    let legacyMessage = XXLegacyDatabaseMigrator.GroupMessage.stub(
      1,
      from: sender.id,
      toGroup: "unknown-group-id".data(using: .utf8)!,
      status: .sent
    )

    XCTAssertThrowsError(try migrate(legacyMessage, to: newDb)) { error in
      XCTAssertEqual(
        error as? MigrateMessage.GroupNotFound,
        MigrateMessage.GroupNotFound()
      )
    }
  }

  func testMigratingReplyMessage() throws {
    let contact1 = try newDb.saveContact(.stub(1))
    let contact2 = try newDb.saveContact(.stub(2))
    let originMessage = try newDb.saveMessage(.stub(
      1,
      from: contact1.id,
      to: contact2.id,
      status: .sent
    ))

    let legacyMessage = XXLegacyDatabaseMigrator.Message.stub(
      2,
      from: contact2.id,
      to: contact1.id,
      status: .received,
      reply: .init(
        messageId: originMessage.networkId!,
        senderId: originMessage.senderId
      )
    )

    try migrate(legacyMessage, to: newDb)

    let newMessages: [XXModels.Message] = try newDb.fetchMessages(.init()).map {
      $0.withNilId()
    }

    XCTAssertNoDifference(newMessages, [
      originMessage.withNilId(),
      .stub(
        2,
        from: contact2.id,
        to: contact1.id,
        status: .received,
        replyMessageId: originMessage.networkId!
      ),
    ])
  }

  func testMigratingReplyToMessageWithEmptyId() throws {
    let contact1 = try newDb.saveContact(.stub(1))
    let contact2 = try newDb.saveContact(.stub(2))

    let legacyMessage = XXLegacyDatabaseMigrator.Message.stub(
      1,
      from: contact1.id,
      to: contact2.id,
      status: .received,
      reply: .init(
        messageId: "".data(using: .utf8)!,
        senderId: contact2.id
      )
    )

    try migrate(legacyMessage, to: newDb)

    let newMessages: [XXModels.Message] = try newDb.fetchMessages(.init()).map {
      $0.withNilId()
    }

    XCTAssertNoDifference(newMessages, [
      .stub(
        1,
        from: contact1.id,
        to: contact2.id,
        status: .received,
        replyMessageId: nil
      ),
    ])
  }

  func testMigratingFileTransfer() throws {
    let contact1 = try newDb.saveContact(.stub(1))
    let contact2 = try newDb.saveContact(.stub(2))

    let legacyMessages: [XXLegacyDatabaseMigrator.Message] = [
      .stub(
        1,
        from: contact1.id,
        to: contact2.id,
        status: .received,
        attachment: .stub(1, ext: .image, progress: 0.1)
      ),
      .stub(
        2,
        from: contact2.id,
        to: contact1.id,
        status: .sent,
        attachment: .stub(2, ext: .audio, progress: 0.2)
      ),
    ]

    try legacyMessages.forEach { message in
      try migrate(message, to: newDb)
    }

    let newMessages: [XXModels.Message] = try newDb.fetchMessages(.init())
      .map { $0.withNilId() }

    XCTAssertNoDifference(newMessages, [
      .stub(
        1,
        from: contact1.id,
        to: contact2.id,
        status: .received,
        fileTransferId: legacyMessages[0].payload.attachment!.transferId!
      ),
      .stub(
        2,
        from: contact2.id,
        to: contact1.id,
        status: .sent,
        fileTransferId: legacyMessages[1].payload.attachment!.transferId!
      ),
    ])

    XCTAssertNoDifference(try newDb.fetchFileTransfers(.init(sortBy: .createdAt())), [
      .stub(
        1,
        contactId: contact1.id,
        type: "jpeg",
        progress: 0.1,
        isIncoming: true,
        createdAt: Date(nsSince1970: legacyMessages[0].timestamp)
      ),
      .stub(
        2,
        contactId: contact1.id,
        type: "m4a",
        progress: 0.2,
        isIncoming: false,
        createdAt: Date(nsSince1970: legacyMessages[1].timestamp)
      )
    ])
  }
}
