import GRDB
import XXModels

extension Database {
  @discardableResult
  public func insert<Record>(
    _ record: Record
  ) throws -> Record
  where Record: MutablePersistableRecord {
    try queue.sync {
      try writer.write { db in
        try record.inserted(db)
      }
    }
  }

  public func insert<Record>() -> Insert<Record>
  where Record: MutablePersistableRecord {
    Insert { record in
      try insert(record)
    }
  }
}
