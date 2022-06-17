import GRDB
import XXModels

public struct MigrateGroup {
  var run: (Group, XXModels.Database) throws -> Void

  func callAsFunction(
    _ group: Group,
    to newDb: XXModels.Database
  ) throws {
    try run(group, newDb)
  }
}

extension MigrateGroup {
  public static let live = MigrateGroup { group, newDb in
    // TODO: migrate group
  }
}
