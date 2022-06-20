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

    let newMessages: [XXModels.Message] = try newDb.fetchMessages(.init()).map {
      var message = $0
      message.id = nil
      return message
    }

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

    let newMessages: [XXModels.Message] = try newDb.fetchMessages(.init()).map {
      var message = $0
      message.id = nil
      return message
    }

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

    let newMessages: [XXModels.Message] = try newDb.fetchMessages(.init()).map {
      var message = $0
      message.id = nil
      return message
    }

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
    // TODO:
  }

  func testMigratingIncomingFileTransfer() throws {
    // TODO:
  }

  func testMigratingOutgoingFileTransfer() throws {
    // TODO:
  }
}
