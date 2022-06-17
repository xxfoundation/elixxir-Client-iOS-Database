import CustomDump
import GRDB
import XCTest
import XXDatabase
import XXModels
@testable import XXLegacyDatabaseMigrator

final class MigratorTests: XCTestCase {
  func testMigrator() throws {
    // Mock up legacy database:

    let legacyDb = try LegacyDatabase(writer: DatabaseQueue())
    try legacyDb.writer.write { db in
      _ = try XXLegacyDatabaseMigrator.Contact.stub(1).saved(db)
      _ = try XXLegacyDatabaseMigrator.Contact.stub(2).saved(db)
      _ = try XXLegacyDatabaseMigrator.Contact.stub(3).saved(db)

      // TODO: mock up legacy groups
      // TODO: mock up legacy group members
      // TODO: mock up legacy messages
      // TODO: mock up legacy group messages
    }

    // Perform migration:

    enum Migrated: Equatable {
      case contact(XXLegacyDatabaseMigrator.Contact)
      case group(XXLegacyDatabaseMigrator.Group)
      case groupMember(XXLegacyDatabaseMigrator.GroupMember)
      case message(XXLegacyDatabaseMigrator.Message)
      case groupMessage(XXLegacyDatabaseMigrator.GroupMessage)
    }

    var didMigrate = [Migrated]()

    let migrate = Migrator.live(
      migrateContact: .init { contact, _ in
        didMigrate.append(.contact(contact))
      },
      migrateGroup: .init { group, _ in
        didMigrate.append(.group(group))
      },
      migrateGroupMember: .init { groupMember, _ in
        didMigrate.append(.groupMember(groupMember))
      },
      migrateMessage: .init { message, _ in
        didMigrate.append(.message(message))
      },
      migrateGroupMessage: .init { groupMessage, _ in
        didMigrate.append(.groupMessage(groupMessage))
      }
    )

    try migrate(from: legacyDb, to: .failing)

    // Assert migration:

    XCTAssertNoDifference(didMigrate, try legacyDb.writer.read { db in
      [
        try XXLegacyDatabaseMigrator.Contact
          .order(XXLegacyDatabaseMigrator.Contact.Column.createdAt)
          .fetchAll(db)
          .map(Migrated.contact),

        try XXLegacyDatabaseMigrator.Group
          .order(XXLegacyDatabaseMigrator.Group.Column.createdAt)
          .fetchAll(db)
          .map(Migrated.group),

        try XXLegacyDatabaseMigrator.GroupMember
          .order(XXLegacyDatabaseMigrator.GroupMember.Column.username)
          .fetchAll(db)
          .map(Migrated.groupMember),

        try XXLegacyDatabaseMigrator.Message
          .order(XXLegacyDatabaseMigrator.Message.Column.timestamp)
          .fetchAll(db)
          .map(Migrated.message),

        try XXLegacyDatabaseMigrator.GroupMessage
          .order(XXLegacyDatabaseMigrator.GroupMessage.Column.timestamp)
          .fetchAll(db)
          .map(Migrated.groupMessage),

      ].flatMap { $0 }
    })
  }
}
