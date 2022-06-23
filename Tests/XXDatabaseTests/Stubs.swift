import Foundation
import XXModels

extension Date {
  static func stub(_ ti: TimeInterval) -> Date {
    Date(timeIntervalSince1970: ti)
  }
}

extension Contact {
  static func stub(
    _ id: String,
    authStatus: AuthStatus = .stranger,
    isRecent: Bool = false,
    createdAt: Date = .stub(0)
  ) -> Contact {
    Contact(
      id: "contact-id-\(id)".data(using: .utf8)!,
      marshaled: "contact-marshaled-\(id)".data(using: .utf8)!,
      username: "contact-username-\(id)",
      email: "contact-\(id)@elixxir.io",
      phone: "contact-phone-\(id)",
      nickname: "contact-nickname-\(id)",
      authStatus: authStatus,
      isRecent: isRecent,
      createdAt: createdAt
    )
  }

  func withAuthStatus(_ authStatus: AuthStatus) -> Contact {
    var contact = self
    contact.authStatus = authStatus
    return contact
  }
}

extension Group {
  static func stub(
    _ id: String,
    leaderId: Data,
    createdAt: Date,
    authStatus: AuthStatus = .pending
  ) -> Group {
    Group(
      id: "group-id-\(id)".data(using: .utf8)!,
      name: "group-name-\(id)",
      leaderId: leaderId,
      createdAt: createdAt,
      authStatus: authStatus,
      serialized: "group-serialized-\(id)".data(using: .utf8)!
    )
  }
}

extension Message {
  static func stub(
    from sender: Contact,
    to recipient: Contact,
    at timeInterval: TimeInterval,
    networkId: Data? = nil,
    status: Status = .received,
    isUnread: Bool = false,
    fileTransfer: FileTransfer? = nil
  ) -> Message {
    Message(
      networkId: networkId,
      senderId: sender.id,
      recipientId: recipient.id,
      groupId: nil,
      date: .stub(timeInterval),
      status: status,
      isUnread: isUnread,
      text: "\(sender.username ?? "?") → \(recipient.username ?? "?") @ \(timeInterval)",
      fileTransferId: fileTransfer?.id
    )
  }

  static func stub(
    from sender: Contact,
    to group: Group,
    at timeInterval: TimeInterval,
    networkId: Data? = nil,
    status: Status = .received,
    isUnread: Bool = false,
    fileTransfer: FileTransfer? = nil
  ) -> Message {
    Message(
      networkId: networkId,
      senderId: sender.id,
      recipientId: nil,
      groupId: group.id,
      date: .stub(timeInterval),
      status: status,
      isUnread: isUnread,
      text: "\(sender.username ?? "?") → G:\(group.name) @ \(timeInterval)",
      fileTransferId: fileTransfer?.id
    )
  }

  func withIsUnread(_ isUnread: Bool) -> Message {
    var contact = self
    contact.isUnread = isUnread
    return contact
  }

  func withStatus(_ status: Status) -> Message {
    var contact = self
    contact.status = status
    return contact
  }
}

extension FileTransfer {
  static func stub(
    _ id: String,
    contact: Contact,
    isIncoming: Bool,
    at timeInterval: TimeInterval
  ) -> FileTransfer {
    FileTransfer(
      id: "file-transfer-\(id)".data(using: .utf8)!,
      contactId: contact.id,
      name: "file-name-\(id)",
      type: "file-type-\(id)",
      isIncoming: isIncoming,
      createdAt: .stub(timeInterval)
    )
  }
}
