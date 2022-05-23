import Foundation
import XXModels

extension Date {
  static func stub(_ ti: TimeInterval) -> Date {
    Date(timeIntervalSince1970: ti)
  }
}

extension Contact {
  static func stub(_ id: String) -> Contact {
    Contact(
      id: "contact-id-\(id)".data(using: .utf8)!,
      marshaled: "contact-marshaled-\(id)".data(using: .utf8)!,
      username: "contact-username-\(id)",
      email: "contact-\(id)@elixxir.io",
      phone: "contact-phone-\(id)",
      nickname: "contact-nickname-\(id)"
    )
  }
}

extension Group {
  static func stub(_ id: String, leaderId: Data, createdAt: Date) -> Group {
    Group(
      id: "group-id-\(id)".data(using: .utf8)!,
      name: "group-name-\(id)",
      leaderId: leaderId,
      createdAt: createdAt
    )
  }
}

extension Message {
  static func stub(
    senderId: Data,
    recipientId: Data?,
    groupId: Data?,
    date: Date,
    isUnread: Bool = false,
    text: String
  ) -> Message {
    Message(
      senderId: senderId,
      recipientId: recipientId,
      groupId: groupId,
      date: date,
      isUnread: isUnread,
      text: text
    )
  }

  static func stub(
    from sender: Contact,
    to recipient: Contact,
    at timeInterval: TimeInterval,
    isUnread: Bool = false
  ) -> Message {
    Message(
      senderId: sender.id,
      recipientId: recipient.id,
      groupId: nil,
      date: .stub(timeInterval),
      isUnread: isUnread,
      text: "\(sender.username ?? "?") → \(recipient.username ?? "?") @ \(timeInterval)"
    )
  }

  static func stub(
    from sender: Contact,
    to group: Group,
    at timeInterval: TimeInterval,
    isUnread: Bool = false
  ) -> Message {
    Message(
      senderId: sender.id,
      recipientId: nil,
      groupId: group.id,
      date: .stub(timeInterval),
      isUnread: isUnread,
      text: "\(sender.username ?? "?") → G:\(group.name) @ \(timeInterval)"
    )
  }
}
