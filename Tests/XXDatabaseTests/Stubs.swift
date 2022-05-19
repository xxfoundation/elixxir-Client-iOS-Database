import Foundation
import XXModels

extension Date {
  static func stub(_ ti: TimeInterval) -> Date {
    Date(timeIntervalSince1970: ti)
  }
}

extension Contact {
  static func stub(_ id: Int) -> Contact {
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
  static func stub(_ id: Int, leaderId: Data) -> Group {
    Group(
      id: "group-id-\(id)".data(using: .utf8)!,
      name: "group-name-\(id)",
      leaderId: leaderId,
      createdAt: Date.stub(TimeInterval(id))
    )
  }
}

extension Message {
  static func stub(
    senderId: Data,
    recipientId: Data,
    date: Date,
    text: String
  ) -> Message {
    Message(
      id: nil,
      networkId: nil,
      senderId: senderId,
      recipientId: recipientId,
      date: date,
      isUnread: true,
      text: text
    )
  }
}
