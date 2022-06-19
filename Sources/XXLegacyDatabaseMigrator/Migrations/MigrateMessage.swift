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
  public static let live = MigrateMessage { message, newDb in
    // TODO: migrate message
  }
}
