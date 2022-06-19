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
    if let replyMessageId = message.payload.reply?.messageId {
      guard let repliedMessage = try newDb.fetchMessages(.init(networkId: replyMessageId)).first
      else { throw ReplyMessageNotFound() }
    }

    // TODO: migrate message
  }
}
