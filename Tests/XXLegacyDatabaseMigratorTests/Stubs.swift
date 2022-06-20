import Foundation
import XXModels
@testable import XXLegacyDatabaseMigrator

extension Date {
  static func stub(_ ti: TimeInterval) -> Date {
    Date(timeIntervalSince1970: ti)
  }
}

extension XXLegacyDatabaseMigrator.Contact {
  static func stub(
    _ stubId: Int,
    status: Status = .friend,
    isRecent: Bool = false
  ) -> XXLegacyDatabaseMigrator.Contact {
    XXLegacyDatabaseMigrator.Contact(
      id: nil,
      photo: "photo-\(stubId)".data(using: .utf8)!,
      userId: "user-id-\(stubId)".data(using: .utf8)!,
      email: "email-\(stubId)",
      phone: "phone-\(stubId)",
      status: status,
      marshaled: "marshaled-\(stubId)".data(using: .utf8)!,
      createdAt: .stub(TimeInterval(stubId)),
      username: "username-\(stubId)",
      nickname: "nickname-\(stubId)",
      isRecent: isRecent
    )
  }
}

extension XXModels.Contact {
  static func stub(
    _ stubId: Int,
    authStatus: AuthStatus = .friend,
    isRecent: Bool = false
  ) -> XXModels.Contact {
    XXModels.Contact(
      id: "user-id-\(stubId)".data(using: .utf8)!,
      marshaled: "marshaled-\(stubId)".data(using: .utf8)!,
      username: "username-\(stubId)",
      email: "email-\(stubId)",
      phone: "phone-\(stubId)",
      nickname: "nickname-\(stubId)",
      photo: "photo-\(stubId)".data(using: .utf8)!,
      authStatus: authStatus,
      isRecent: isRecent,
      createdAt: .stub(TimeInterval(stubId))
    )
  }
}

extension XXLegacyDatabaseMigrator.Group {
  static func stub(
    _ stubId: Int,
    leader: Data? = nil,
    status: Status = .participating
  ) -> XXLegacyDatabaseMigrator.Group {
    XXLegacyDatabaseMigrator.Group(
      id: nil,
      name: "name-\(stubId)",
      leader: leader ?? "group-leader-\(stubId)".data(using: .utf8)!,
      groupId: "group-id-\(stubId)".data(using: .utf8)!,
      status: status,
      serialize: "serialize-\(stubId)".data(using: .utf8)!,
      createdAt: .stub(TimeInterval(stubId))
    )
  }
}

extension XXModels.Group {
  static func stub(
    _ stubId: Int,
    leaderId: XXModels.Contact.ID? = nil,
    authStatus: AuthStatus = .participating
  ) -> XXModels.Group {
    XXModels.Group(
      id: "group-id-\(stubId)".data(using: .utf8)!,
      name: "name-\(stubId)",
      leaderId: leaderId ?? "group-leader-\(stubId)".data(using: .utf8)!,
      createdAt: .stub(TimeInterval(stubId)),
      authStatus: authStatus,
      serialized: "serialize-\(stubId)".data(using: .utf8)!
    )
  }
}

extension XXLegacyDatabaseMigrator.GroupMember {
  static func stub(
    _ stubId: Int,
    userId: Data? = nil,
    groupId: Data? = nil,
    status: Status = .usernameSet
  ) -> XXLegacyDatabaseMigrator.GroupMember {
    XXLegacyDatabaseMigrator.GroupMember(
      id: nil,
      userId: userId ?? "user-id-\(stubId)".data(using: .utf8)!,
      groupId: groupId ?? "group-id-\(stubId)".data(using: .utf8)!,
      status: status,
      username: "username-\(stubId)",
      photo: "photo-\(stubId)".data(using: .utf8)!
    )
  }
}

extension XXLegacyDatabaseMigrator.Message {
  static func stub(_ stubId: Int) -> XXLegacyDatabaseMigrator.Message {
    XXLegacyDatabaseMigrator.Message(
      id: nil,
      unread: false,
      sender: "sender-\(stubId)".data(using: .utf8)!,
      roundURL: "round-url-\(stubId)",
      report: "report-\(stubId)".data(using: .utf8)!,
      status: .received,
      receiver: "receiver-\(stubId)".data(using: .utf8)!,
      timestamp: stubId,
      uniqueId: "unique-id-\(stubId)".data(using: .utf8)!,
      payload: Payload(
        text: "text-\(stubId)",
        reply: .init(
          messageId: "reply-message-id-\(stubId)".data(using: .utf8)!,
          senderId: "reply-sender-id-\(stubId)".data(using: .utf8)!
        ),
        attachment: .init(
          data: "attachment-data-\(stubId)".data(using: .utf8)!,
          name: "attachment-name-\(stubId)",
          transferId: "attachment-tid-\(stubId)".data(using: .utf8)!,
          _extension: .image,
          progress: 0.5
        )
      )
    )
  }

  static func stub(
    _ stubId: Int,
    from sender: Data,
    to receiver: Data,
    status: Status,
    unread: Bool = false,
    reply: Reply? = nil,
    attachment: Attachment? = nil
  ) -> XXLegacyDatabaseMigrator.Message {
    XXLegacyDatabaseMigrator.Message(
      id: nil,
      unread: unread,
      sender: sender,
      roundURL: "round-url-\(stubId)",
      report: "report-\(stubId)".data(using: .utf8)!,
      status: status,
      receiver: receiver,
      timestamp: stubId * Int(NSEC_PER_SEC),
      uniqueId: "network-id-\(stubId)".data(using: .utf8)!,
      payload: Payload(
        text: "text-\(stubId)",
        reply: reply,
        attachment: attachment
      )
    )
  }
}

extension XXModels.Message {
  static func stub(
    _ stubId: Int,
    from senderId: XXModels.Contact.ID,
    to recipientId: XXModels.Contact.ID,
    status: Status,
    isUnread: Bool = false,
    replyMessageId: Data? = nil,
    fileTransferId: Data? = nil
  ) -> XXModels.Message {
    XXModels.Message(
      id: nil,
      networkId: "network-id-\(stubId)".data(using: .utf8)!,
      senderId: senderId,
      recipientId: recipientId,
      groupId: nil,
      date: .stub(TimeInterval(stubId)),
      status: status,
      isUnread: isUnread,
      text: "text-\(stubId)",
      replyMessageId: replyMessageId,
      roundURL: "round-url-\(stubId)",
      fileTransferId: fileTransferId
    )
  }

  static func stub(
    _ stubId: Int,
    from senderId: XXModels.Contact.ID,
    toGroup groupId: XXModels.Group.ID,
    status: Status,
    isUnread: Bool = false
  ) -> XXModels.Message {
    XXModels.Message(
      id: nil,
      networkId: "network-id-\(stubId)-group".data(using: .utf8)!,
      senderId: senderId,
      recipientId: nil,
      groupId: groupId,
      date: .stub(TimeInterval(stubId)),
      status: status,
      isUnread: isUnread,
      text: "text-\(stubId)",
      replyMessageId: nil,
      roundURL: "round-url-\(stubId)",
      fileTransferId: nil
    )
  }

  func withNilId() -> XXModels.Message {
    var message = self
    message.id = nil
    return message
  }
}

extension XXLegacyDatabaseMigrator.GroupMessage {
  static func stub(_ stubId: Int) -> XXLegacyDatabaseMigrator.GroupMessage {
    XXLegacyDatabaseMigrator.GroupMessage(
      id: nil,
      uniqueId: "group-message-unique-id-\(stubId)".data(using: .utf8)!,
      groupId: "group-id-\(stubId)".data(using: .utf8)!,
      sender: "sender-\(stubId)".data(using: .utf8)!,
      roundId: Int64(stubId),
      payload: Payload(
        text: "text-\(stubId)",
        reply: .init(
          messageId: "reply-message-id-\(stubId)".data(using: .utf8)!,
          senderId: "reply-sender-id-\(stubId)".data(using: .utf8)!
        ),
        attachment: .init(
          data: "attachment-data-\(stubId)".data(using: .utf8)!,
          name: "attachment-name-\(stubId)",
          transferId: "attachment-tid-\(stubId)".data(using: .utf8)!,
          _extension: .image,
          progress: 0.5
        )
      ),
      status: .received,
      roundURL: "round-url-\(stubId)",
      unread: false,
      timestamp: stubId * Int(NSEC_PER_SEC)
    )
  }

  static func stub(
    _ stubId: Int,
    from sender: Data,
    toGroup groupId: Data,
    status: Status,
    unread: Bool = false
  ) -> XXLegacyDatabaseMigrator.GroupMessage {
    XXLegacyDatabaseMigrator.GroupMessage(
      id: nil,
      uniqueId: "network-id-\(stubId)-group".data(using: .utf8)!,
      groupId: groupId,
      sender: sender,
      roundId: nil,
      payload: Payload(
        text: "text-\(stubId)",
        reply: nil,
        attachment: nil
      ),
      status: status,
      roundURL: "round-url-\(stubId)",
      unread: unread,
      timestamp: stubId * Int(NSEC_PER_SEC)
    )
  }
}

extension XXLegacyDatabaseMigrator.Attachment {
  static func stub(
    _ stubId: Int,
    ext: Extension,
    progress: Float
  ) -> XXLegacyDatabaseMigrator.Attachment {
    XXLegacyDatabaseMigrator.Attachment(
      data: "attachment-data-\(stubId)".data(using: .utf8)!,
      name: "attachment-name-\(stubId)",
      transferId: "attachment-tid-\(stubId)".data(using: .utf8)!,
      _extension: ext,
      progress: progress
    )
  }
}

extension XXModels.FileTransfer {
  static func stub(
    _ stubId: Int,
    contactId: XXModels.Contact.ID,
    type: String,
    progress: Float,
    isIncoming: Bool,
    createdAt: Date
  ) -> XXModels.FileTransfer {
    XXModels.FileTransfer(
      id: "attachment-tid-\(stubId)".data(using: .utf8)!,
      contactId: contactId,
      name: "attachment-name-\(stubId)",
      type: type,
      data: "attachment-data-\(stubId)".data(using: .utf8)!,
      progress: progress,
      isIncoming: isIncoming,
      createdAt: createdAt
    )
  }
}
