import CustomDump
import GRDB
import XCTest
import XXModels
@testable import XXDatabase
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

    // Mock up new database:

    var didSaveContacts = [XXModels.Contact]()

    var newDb = XXModels.Database.failing
    newDb.fetchContacts = .init { _ in [] }
    newDb.saveContact = .init(run: {
      didSaveContacts.append($0)
      return $0
    })

    // Perform migration:

    enum Migrated: Equatable {
      case contact(XXLegacyDatabaseMigrator.Contact)
      case group(XXLegacyDatabaseMigrator.Group)
      case groupMember(XXLegacyDatabaseMigrator.GroupMember)
      case message(XXLegacyDatabaseMigrator.LegacyMessage, Data, Data)
    }

    let currentDate = Date()
    var didMigrate = [Migrated]()

    let migrate = Migrator.live(
      currentDate: {
        currentDate
      },
      migrateContact: .init { contact, _ in
        didMigrate.append(.contact(contact))
      },
      migrateGroup: .init { group, _ in
        didMigrate.append(.group(group))
      },
      migrateGroupMember: .init { groupMember, _ in
        didMigrate.append(.groupMember(groupMember))
      },
      migrateMessage: .init { message, _, myContactId, meMarshaled in
        didMigrate.append(.message(message, myContactId, meMarshaled))
      }
    )

    let myContactId = "my-contact-id".data(using: .utf8)!
    let meMarshaled = "me-marshaled".data(using: .utf8)!

    try migrate(legacyDb, to: newDb, myContactId: myContactId, meMarshaled: meMarshaled)

    // Assert migration:

    XCTAssertNoDifference(didSaveContacts, [
      .init(id: myContactId, marshaled: meMarshaled, createdAt: currentDate)
    ])

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
          .map(XXLegacyDatabaseMigrator.LegacyMessage.direct)
          .map { Migrated.message($0, myContactId, meMarshaled) },

        try XXLegacyDatabaseMigrator.GroupMessage
          .order(XXLegacyDatabaseMigrator.GroupMessage.Column.timestamp)
          .fetchAll(db)
          .map(XXLegacyDatabaseMigrator.LegacyMessage.group)
          .map { Migrated.message($0, myContactId, meMarshaled) },

      ].flatMap { $0 }
    })
  }

  func testMigratingLegacyDatabase1() throws {
    let path = Bundle.module.path(forResource: "legacy_database_1", ofType: "sqlite")!
    let legacyDb = try LegacyDatabase(path: path)
    let newDbQueue = DatabaseQueue()
    let newDb = try XXModels.Database.grdb(writer: newDbQueue)
    let currentDate = Date(timeIntervalSince1970: 1234)
    let migrate = Migrator.live(currentDate: { currentDate })

    let myContactId = "my-contact-id".data(using: .utf8)!
    let meMarshaled = Data(base64Encoded: try String(
      contentsOfFile: Bundle.module.path(
        forResource: "legacy_database_1_meMarshaled_base64",
        ofType: "txt"
      )!
    ).trimmingCharacters(in: .whitespacesAndNewlines))!

    try migrate(legacyDb, to: newDb, myContactId: myContactId, meMarshaled: meMarshaled)

    assertSnapshot(matchingContactsIn: newDbQueue)
    assertSnapshot(matchingGroupsIn: newDbQueue)
    assertSnapshot(matchingGroupMembersIn: newDbQueue)
    assertSnapshot(matchingMessagesIn: newDbQueue)
    assertSnapshot(matchingFileTransfersIn: newDbQueue)
  }

  func testMigratingLegacyDatabase2() throws {
    let path = Bundle.module.path(forResource: "legacy_database_2", ofType: "sqlite")!
    let legacyDb = try LegacyDatabase(path: path)
    let newDbQueue = DatabaseQueue()
    let newDb = try XXModels.Database.grdb(writer: newDbQueue)
    let currentDate = Date(timeIntervalSince1970: 1234)
    let migrate = Migrator.live(currentDate: { currentDate })

    let myContactId = "my-contact-id".data(using: .utf8)!
    let meMarshaled = Data(base64Encoded: try String(
      contentsOfFile: Bundle.module.path(
        forResource: "legacy_database_2_meMarshaled_base64",
        ofType: "txt"
      )!
    ).trimmingCharacters(in: .whitespacesAndNewlines))!

    try migrate(legacyDb, to: newDb, myContactId: myContactId, meMarshaled: meMarshaled)

    assertSnapshot(matchingContactsIn: newDbQueue)
    assertSnapshot(matchingGroupsIn: newDbQueue)
    assertSnapshot(matchingGroupMembersIn: newDbQueue)
    assertSnapshot(matchingMessagesIn: newDbQueue)
    assertSnapshot(matchingFileTransfersIn: newDbQueue)
  }
}
