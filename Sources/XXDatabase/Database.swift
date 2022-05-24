import Combine
import Foundation
import GRDB

public struct Database {
  let writer: DatabaseWriter
  let queue: DispatchQueue

  private func migrate(_ migrations: [Migration]) throws {
    var migrator = DatabaseMigrator()
    migrations.forEach { migration in
      migrator.registerMigration(migration.id, migrate: migration.migrate)
    }
    try migrator.migrate(writer)
  }
}

extension Database {
  public static func inMemory(migrations: [Migration] = .all) throws -> Database {
    let db = Database(
      writer: DatabaseQueue(),
      queue: DispatchQueue(label: "XXDatabase")
    )
    try db.migrate(migrations)
    return db
  }
}
