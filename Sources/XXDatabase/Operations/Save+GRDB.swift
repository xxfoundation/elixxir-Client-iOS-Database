import GRDB
import XXModels

extension Database {
  @discardableResult
  public func save<Record>(
    _ record: Record
  ) throws -> Record
  where Record: MutablePersistableRecord {
    try queue.sync {
      try writer.write { db in
        try record.saved(db)
      }
    }
  }

  public func save<Record>() -> Save<Record>
  where Record: MutablePersistableRecord {
    Save { record in
      try save(record)
    }
  }
}
