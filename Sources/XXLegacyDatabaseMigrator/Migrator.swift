import Foundation
import XXModels

/// Legacy database migrator
///
/// Use it to migrate legacy database to new database.
public struct Migrator {
  public var run: (LegacyDatabase, XXModels.Database, Data, Data) throws -> Void

  public func callAsFunction(
    _ legacyDb: LegacyDatabase,
    to newDb: XXModels.Database,
    myContactId: Data,
    meMarshaled: Data
  ) throws {
    try run(legacyDb, newDb, myContactId, meMarshaled)
  }
}

extension Migrator {
  /// Live migrator implementation
  public static func live(
    currentDate: @escaping () -> Date = Date.init,
    migrateContact: MigrateContact = .live,
    migrateGroup: MigrateGroup = .live,
    migrateGroupMember: MigrateGroupMember = .live,
    migrateMessage: MigrateMessage = .live
  ) -> Migrator {
    Migrator { legacyDb, newDb, myContactId, meMarshaled in
      if try newDb.fetchContacts(.init(id: [myContactId])).isEmpty {
        try newDb.saveContact(.init(
          id: myContactId,
          marshaled: meMarshaled,
          authStatus: .friend,
          createdAt: currentDate()
        ))
      }

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
          try migrateMessage(message, to: newDb, myContactId: myContactId, meMarshaled: meMarshaled)
        }

        let groupMessages = try GroupMessage.order(GroupMessage.Column.timestamp).fetchCursor(db)
        while let groupMessage = try groupMessages.next() {
          do {
            try migrateMessage(groupMessage, to: newDb, myContactId: myContactId, meMarshaled: meMarshaled)
          }
          catch _ as MigrateMessage.GroupNotFound {}
        }
      }
    }
  }
}

#if DEBUG
import XCTestDynamicOverlay

extension Migrator {
  public static let failing = Migrator { _, _, _, _ in fatalError() }

  public static let unimplemented = Migrator(
    run: XCTUnimplemented("\(Self.self)")
  )
}
#endif
