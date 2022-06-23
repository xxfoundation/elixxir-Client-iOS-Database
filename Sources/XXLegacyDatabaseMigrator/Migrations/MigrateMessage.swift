import Foundation
import GRDB
import XXModels

public struct MigrateMessage {
  var run: (LegacyMessage, XXModels.Database, Data, Data) throws -> Void

  func callAsFunction(
    _ message: Message,
    to newDb: XXModels.Database,
    myContactId: Data,
    meMarshaled: Data
  ) throws {
    try run(.direct(message), newDb, myContactId, meMarshaled)
  }

  func callAsFunction(
    _ message: GroupMessage,
    to newDb: XXModels.Database,
    myContactId: Data,
    meMarshaled: Data
  ) throws {
    try run(.group(message), newDb, myContactId, meMarshaled)
  }
}

extension MigrateMessage {
  public struct ReplyMessageNotFound: Error, Equatable {}
  public struct GroupNotFound: Error, Equatable {}

  public static let live = MigrateMessage { message, newDb, myContactId, meMarshaled in
    let message: LegacyMessage = {
      switch message {
      case .direct(var message):
        if message.sender == meMarshaled {
          message.sender = myContactId
        }
        if message.receiver == meMarshaled {
          message.receiver = myContactId
        }
        return .direct(message)

      case .group(var groupMessage):
        if groupMessage.sender == meMarshaled {
          groupMessage.sender = myContactId
        }
        return .group(groupMessage)
      }
    }()

    let replyMessageId: Data?
    if let id = message.payload.reply?.messageId, id != "".data(using: .utf8) {
      replyMessageId = id
    } else {
      replyMessageId = nil
    }

    if let replyMessageId = replyMessageId,
       try newDb.fetchMessages(.init(networkId: replyMessageId)).isEmpty {
      throw ReplyMessageNotFound()
    }

    if let groupId = message.groupId,
       try newDb.fetchGroups(.init(id: [groupId])).isEmpty {
      throw GroupNotFound()
    }

    if try newDb.fetchContacts(.init(id: [message.sender])).isEmpty {
      try newDb.saveContact(.init(
        id: message.sender,
        createdAt: Date(nsSince1970: message.timestamp)
      ))
    }

    if let receiver = message.receiver,
       try newDb.fetchContacts(.init(id: [receiver])).isEmpty {
      try newDb.saveContact(.init(
        id: receiver,
        createdAt: Date(nsSince1970: message.timestamp)
      ))
    }

    let fileTransfer: XXModels.FileTransfer?
    if let ft = Self.fileTransfer(for: message) {
      fileTransfer = try newDb.saveFileTransfer(ft)
    } else {
      fileTransfer = nil
    }

    let status: XXModels.Message.Status
    switch message {
    case .direct(let message):
      status = newStatus(for: message.status)
    case .group(let groupMessage):
      status = newStatus(for: groupMessage.status)
    }

    try newDb.saveMessage(.init(
      id: nil,
      networkId: message.uniqueId,
      senderId: message.sender,
      recipientId: message.receiver,
      groupId: message.groupId,
      date: Date(nsSince1970: message.timestamp),
      status: status,
      isUnread: message.unread,
      text: message.payload.text,
      replyMessageId: replyMessageId,
      roundURL: message.roundURL,
      fileTransferId: fileTransfer?.id
    ))
  }

  static func newStatus(
    for status: XXLegacyDatabaseMigrator.Message.Status
  ) -> XXModels.Message.Status {
    switch status {
    case .read: return .received
    case .sent: return .sent
    case .sending: return .sending
    case .sendingAttachment: return .sending
    case .receivingAttachment: return .receiving
    case .received: return .received
    case .failedToSend: return .sendingFailed
    case .timedOut: return .sendingTimedOut
    }
  }

  static func newStatus(
    for status: XXLegacyDatabaseMigrator.GroupMessage.Status
  ) -> XXModels.Message.Status {
    switch status {
    case .sent: return .sent
    case .read: return .received
    case .failed: return .sendingFailed
    case .sending: return .sending
    case .received: return .received
    }
  }

  static func fileTransfer(
    for anyMessage: XXLegacyDatabaseMigrator.LegacyMessage
  ) -> XXModels.FileTransfer? {
    guard case .direct(let message) = anyMessage,
          let attachment = message.payload.attachment,
          let transferId = attachment.transferId
    else {
      return nil
    }

    func contactId() -> Data {
      switch message.status {
      case .read, .receivingAttachment, .received:
        return message.sender
      case .sent, .sending, .sendingAttachment, .failedToSend, .timedOut:
        return message.receiver
      }
    }

    func type() -> String {
      switch attachment._extension {
      case .image: return "jpeg"
      case .audio: return "m4a"
      }
    }

    func isIncoming() -> Bool {
      switch message.status {
      case .read, .receivingAttachment, .received:
        return true
      case .sent, .sending, .sendingAttachment, .failedToSend, .timedOut:
        return false
      }
    }

    return .init(
      id: transferId,
      contactId: contactId(),
      name: attachment.name,
      type: type(),
      data: attachment.data,
      progress: attachment.progress,
      isIncoming: isIncoming(),
      createdAt: Date(nsSince1970: message.timestamp)
    )
  }
}
