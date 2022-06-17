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
    let leaderContact: XXModels.Contact
    if let contact = try newDb.fetchContacts(.init(id: [group.leader])).first {
      leaderContact = contact
    } else {
      leaderContact = try newDb.saveContact(.init(
        id: group.leader,
        createdAt: group.createdAt
      ))
    }

    try newDb.saveGroup(.init(
      id: group.groupId,
      name: group.name,
      leaderId: leaderContact.id,
      createdAt: group.createdAt,
      authStatus: authStatus(for: group.status),
      serialized: group.serialize
    ))
  }

  static func authStatus(
    for status: XXLegacyDatabaseMigrator.Group.Status
  ) -> XXModels.Group.AuthStatus {
    switch status {
    case .hidden: return .hidden
    case .pending: return .pending
    case .deleting: return .deleting
    case .participating: return .participating
    }
  }
}
