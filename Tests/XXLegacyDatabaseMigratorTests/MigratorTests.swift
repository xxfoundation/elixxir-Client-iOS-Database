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

      _ = try XXLegacyDatabaseMigrator.Group.stub(1).saved(db)
      _ = try XXLegacyDatabaseMigrator.Group.stub(2).saved(db)
      _ = try XXLegacyDatabaseMigrator.Group.stub(3).saved(db)

      _ = try XXLegacyDatabaseMigrator.GroupMember.stub(1).saved(db)
      _ = try XXLegacyDatabaseMigrator.GroupMember.stub(2).saved(db)
      _ = try XXLegacyDatabaseMigrator.GroupMember.stub(3).saved(db)

      _ = try XXLegacyDatabaseMigrator.Message.stub(1).saved(db)
      _ = try XXLegacyDatabaseMigrator.Message.stub(2).saved(db)
      _ = try XXLegacyDatabaseMigrator.Message.stub(3).saved(db)

      _ = try XXLegacyDatabaseMigrator.GroupMessage.stub(1).saved(db)
      _ = try XXLegacyDatabaseMigrator.GroupMessage.stub(2).saved(db)
      _ = try XXLegacyDatabaseMigrator.GroupMessage.stub(3).saved(db)
    }

    // Perform migration:

    enum Migrated: Equatable {
      case contact(XXLegacyDatabaseMigrator.Contact)
      case group(XXLegacyDatabaseMigrator.Group)
      case groupMember(XXLegacyDatabaseMigrator.GroupMember)
      case message(XXLegacyDatabaseMigrator.AnyMessage)
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
      }
    )

    try migrate(legacyDb, to: .failing)

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
          .map(XXLegacyDatabaseMigrator.AnyMessage.direct)
          .map(Migrated.message),

        try XXLegacyDatabaseMigrator.GroupMessage
          .order(XXLegacyDatabaseMigrator.GroupMessage.Column.timestamp)
          .fetchAll(db)
          .map(XXLegacyDatabaseMigrator.AnyMessage.group)
          .map(Migrated.message),

      ].flatMap { $0 }
    })
  }
}
