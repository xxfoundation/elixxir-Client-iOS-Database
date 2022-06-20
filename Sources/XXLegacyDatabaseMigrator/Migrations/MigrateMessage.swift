import Foundation
import GRDB
import XXModels

public struct MigrateMessage {
  var run: (AnyMessage, XXModels.Database) throws -> Void

  func callAsFunction(
    _ message: Message,
    to newDb: XXModels.Database
  ) throws {
    try run(.direct(message), newDb)
  }

  func callAsFunction(
    _ message: GroupMessage,
    to newDb: XXModels.Database
  ) throws {
    try run(.group(message), newDb)
  }
}

extension MigrateMessage {
  public struct ReplyMessageNotFound: Error, Equatable {}

  public static let live = MigrateMessage { message, newDb in
    if let replyMessageId = message.payload.reply?.messageId,
       try newDb.fetchMessages(.init(networkId: replyMessageId)).isEmpty {
      throw ReplyMessageNotFound()
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

    if let groupId = message.groupId,
       try newDb.fetchGroups(.init(id: [groupId])).isEmpty {
      // TODO: throw group-not-found error
      fatalError()
    }

    let fileTransfer: XXModels.FileTransfer?
    if let attachment = message.payload.attachment {
      // TODO: create file transfer
      fatalError()
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
      replyMessageId: message.payload.reply?.messageId,
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
}
