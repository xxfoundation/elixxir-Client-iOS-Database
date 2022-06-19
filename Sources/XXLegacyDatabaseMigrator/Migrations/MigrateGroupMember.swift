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
  public struct GroupNotFound: Error, Equatable {}

  public static let live = MigrateGroupMember { groupMember, newDb in
    guard let group = try newDb.fetchGroups(.init(id: [groupMember.groupId])).first else {
      throw GroupNotFound()
    }

    let contact: XXModels.Contact
    if let c = try newDb.fetchContacts(.init(id: [groupMember.userId])).first {
      contact = c
    } else {
      contact = try newDb.saveContact(.init(
        id: groupMember.userId,
        username: groupMember.username,
        photo: groupMember.photo,
        createdAt: group.createdAt
      ))
    }

    try newDb.saveGroupMember(.init(groupId: group.id, contactId: contact.id))
  }
}
