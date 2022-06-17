import CustomDump
import GRDB
import XCTest
import XXDatabase
import XXModels
@testable import XXLegacyDatabaseMigrator

final class MigrateGroupTests: XCTestCase {
  var migrate: MigrateGroup!
  var newDb: XXModels.Database!

  override func setUp() async throws {
    migrate = .live
    newDb = try .inMemory()
  }

  override func tearDown() async throws {
    migrate = nil
    newDb = nil
  }

  func testMigrating() throws {
    let legacyGroups: [XXLegacyDatabaseMigrator.Group] = [
      .stub(1, status: .hidden),
      .stub(2, status: .pending),
      .stub(3, status: .deleting),
      .stub(4, status: .participating),
    ]

    try legacyGroups.forEach { group in
      try migrate(group, to: newDb)
    }

    let newGroups = try newDb.fetchGroups(.init(sortBy: .createdAt()))

    XCTAssertNoDifference(newGroups, [
      .stub(1, authStatus: .hidden),
      .stub(2, authStatus: .pending),
      .stub(3, authStatus: .deleting),
      .stub(4, authStatus: .participating),
    ])
  }

  func testMigratingWhenLeaderContactDoesNotExists() throws {
    let legacyGroup = XXLegacyDatabaseMigrator.Group.stub(1)

    try migrate(legacyGroup, to: newDb)

    let newGroups = try newDb.fetchGroups(.init(sortBy: .createdAt()))
    let newContacts = try newDb.fetchContacts(.init(sortBy: .createdAt()))

    XCTAssertNoDifference(newGroups, [
      .stub(1, leaderId: legacyGroup.leader)
    ])

    XCTAssertNoDifference(newContacts, [
      .init(id: legacyGroup.leader, createdAt: legacyGroup.createdAt),
    ])
  }

  func testMigratingWhenLeaderContactExists() throws {
    let leaderContact = try newDb.saveContact(.stub(1))
    let legacyGroup = XXLegacyDatabaseMigrator.Group.stub(1, leader: leaderContact.id)

    try migrate(legacyGroup, to: newDb)

    let newGroups = try newDb.fetchGroups(.init(sortBy: .createdAt()))
    let newContacts = try newDb.fetchContacts(.init(sortBy: .createdAt()))

    XCTAssertNoDifference(newGroups, [
      .stub(1, leaderId: leaderContact.id)
    ])

    XCTAssertNoDifference(newContacts, [
      leaderContact
    ])
  }
}
