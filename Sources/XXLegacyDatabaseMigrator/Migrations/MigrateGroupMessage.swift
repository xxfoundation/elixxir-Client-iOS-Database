import GRDB
import XXModels

public struct MigrateGroupMessage {
  var run: (GroupMessage, XXModels.Database) throws -> Void

  func callAsFunction(
    _ groupMessage: GroupMessage,
    to newDb: XXModels.Database
  ) throws {
    try run(groupMessage, newDb)
  }
}

extension MigrateGroupMessage {
  public static let live = MigrateGroupMessage { groupMessage, newDb in
    // TODO: migrate group
  }
}
