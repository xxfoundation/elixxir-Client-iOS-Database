import CustomDump
import GRDB
import XCTest
import XXDatabase
import XXModels
@testable import XXLegacyDatabaseMigrator

final class MigrateContactTests: XCTestCase {
  var migrate: MigrateContact!
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
    let legacyContacts: [XXLegacyDatabaseMigrator.Contact] = [
      .stub(1, status: .friend),
      .stub(2, status: .stranger),
      .stub(3, status: .verified),
      .stub(4, status: .verificationFailed),
      .stub(5, status: .verificationInProgress),
      .stub(6, status: .requested),
      .stub(7, status: .requesting),
      .stub(8, status: .requestFailed),
      .stub(9, status: .confirming),
      .stub(10, status: .confirmationFailed),
      .stub(11, status: .hidden),
      .stub(12, isRecent: false),
      .stub(13, isRecent: true),
    ]

    try legacyContacts.forEach { contact in
      try migrate(contact, to: newDb)
    }

    let newContacts = try newDb.fetchContacts(.init(sortBy: .createdAt()))

    XCTAssertNoDifference(newContacts, [
      .stub(1, authStatus: .friend),
      .stub(2, authStatus: .stranger),
      .stub(3, authStatus: .verified),
      .stub(4, authStatus: .verificationFailed),
      .stub(5, authStatus: .verificationInProgress),
      .stub(6, authStatus: .requested),
      .stub(7, authStatus: .requesting),
      .stub(8, authStatus: .requestFailed),
      .stub(9, authStatus: .confirming),
      .stub(10, authStatus: .confirmationFailed),
      .stub(11, authStatus: .hidden),
      .stub(12, isRecent: false),
      .stub(13, isRecent: true),
    ])
  }
}
