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
  static func stub(
    _ stubId: Int,
    unread: Bool = false,
    sender: Data? = nil,
    status: Status = .received,
    receiver: Data? = nil,
    reply: Reply? = nil,
    attachment: Attachment? = nil
  ) -> XXLegacyDatabaseMigrator.Message {
    XXLegacyDatabaseMigrator.Message(
      id: nil,
      unread: unread,
      sender: sender ?? "sender-\(stubId)".data(using: .utf8)!,
      roundURL: "round-url-\(stubId)",
      report: "report-\(stubId)".data(using: .utf8)!,
      status: status,
      receiver: receiver ?? "receiver-\(stubId)".data(using: .utf8)!,
      timestamp: stubId,
      uniqueId: "unique-id-\(stubId)".data(using: .utf8)!,
      payload: Payload(
        text: "text-\(stubId)",
        reply: reply,
        attachment: attachment
      )
    )
  }
}

extension XXLegacyDatabaseMigrator.GroupMessage {
  static func stub(
    _ stubId: Int,
    groupId: Data? = nil,
    sender: Data? = nil,
    reply: Reply? = nil,
    attachment: Attachment? = nil,
    status: Status = .received,
    unread: Bool = false
  ) -> XXLegacyDatabaseMigrator.GroupMessage {
    XXLegacyDatabaseMigrator.GroupMessage(
      id: nil,
      uniqueId: "group-message-unique-id-\(stubId)".data(using: .utf8)!,
      groupId: groupId ?? "group-id-\(stubId)".data(using: .utf8)!,
      sender: sender ?? "sender-\(stubId)".data(using: .utf8)!,
      roundId: Int64(stubId),
      payload: Payload(
        text: "text-\(stubId)",
        reply: reply,
        attachment: attachment
      ),
      status: status,
      roundURL: "round-url-\(stubId)",
      unread: unread,
      timestamp: stubId
    )
  }
}
