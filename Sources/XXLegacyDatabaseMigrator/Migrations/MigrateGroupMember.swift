import GRDB
import XXModels

public struct MigrateGroupMember {
  var run: (GroupMember, XXModels.Database) throws -> Void

  func callAsFunction(
    _ groupMember: GroupMember,
    to newDb: XXModels.Database
  ) throws {
    try run(groupMember, newDb)
  }
}

extension MigrateGroupMember {
  public static let live = MigrateGroupMember { groupMember, newDb in
    // TODO: migrate group member
  }
}
