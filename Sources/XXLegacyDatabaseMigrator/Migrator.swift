import XXModels

/// Legacy database migrator
///
/// Use it to migrate legacy database to new database.
public struct Migrator {
  public var run: (LegacyDatabase, XXModels.Database) throws -> Void

  public func callAsFunction(
    from legacyDb: LegacyDatabase,
    to newDb: XXModels.Database
  ) throws {
    try run(legacyDb, newDb)
  }
}

extension Migrator {
  /// Live migrator implementation
  public static let live = Migrator { legacyDb, newDb in
    // TODO: perform migration
  }
}

#if DEBUG
extension Migrator {
  public static let failing = Migrator { _, _ in fatalError() }
}
#endif
