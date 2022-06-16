import GRDB
import XCTest
import XXDatabase
import XXModels
@testable import XXLegacyDatabaseMigrator

final class MigratorTests: XCTestCase {
  func testMigration() throws {
    // TODO: mock up legacy database

    let legacyDb = try LegacyDatabase(writer: DatabaseQueue())
    let newDb = try XXModels.Database.inMemory()
    let migrate = Migrator.live
    try migrate(from: legacyDb, to: newDb)

    // TODO: assert for data in new database
  }
}
