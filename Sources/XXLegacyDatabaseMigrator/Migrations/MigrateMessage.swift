import GRDB
import XXModels

public struct MigrateMessage {
  var run: (Message, XXModels.Database) throws -> Void

  func callAsFunction(
    _ message: Message,
    to newDb: XXModels.Database
  ) throws {
    try run(message, newDb)
  }
}

extension MigrateMessage {
  public static let live = MigrateMessage { message, newDb in
    // TODO: migrate message
  }
}
