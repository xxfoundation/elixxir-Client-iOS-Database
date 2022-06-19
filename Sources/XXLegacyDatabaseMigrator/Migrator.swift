import XXModels

/// Legacy database migrator
///
/// Use it to migrate legacy database to new database.
public struct Migrator {
  public var run: (LegacyDatabase, XXModels.Database) throws -> Void

  public func callAsFunction(
    _ legacyDb: LegacyDatabase,
    to newDb: XXModels.Database
  ) throws {
    try run(legacyDb, newDb)
  }
}

extension Migrator {
  /// Live migrator implementation
  public static func live(
    migrateContact: MigrateContact = .live,
    migrateGroup: MigrateGroup = .live,
    migrateGroupMember: MigrateGroupMember = .live,
    migrateMessage: MigrateMessage = .live
  ) -> Migrator {
    Migrator { legacyDb, newDb in
      try legacyDb.writer.read { db in
        let contacts = try Contact.order(Contact.Column.createdAt).fetchCursor(db)
        while let contact = try contacts.next() {
          try migrateContact(contact, to: newDb)
        }

        let groups = try Group.order(Group.Column.createdAt).fetchCursor(db)
        while let group = try groups.next() {
          try migrateGroup(group, to: newDb)
        }

        let groupMembers = try GroupMember.order(GroupMember.Column.username).fetchCursor(db)
        while let groupMember = try groupMembers.next() {
          try migrateGroupMember(groupMember, to: newDb)
        }

        let messages = try Message.order(Message.Column.timestamp).fetchCursor(db)
        while let message = try messages.next() {
          try migrateMessage(message, to: newDb)
        }

        let groupMessages = try GroupMessage.order(GroupMessage.Column.timestamp).fetchCursor(db)
        while let groupMessage = try groupMessages.next() {
          try migrateMessage(groupMessage, to: newDb)
        }
      }
    }
  }
}

#if DEBUG
extension Migrator {
  public static let failing = Migrator { _, _ in fatalError() }
}
#endif
