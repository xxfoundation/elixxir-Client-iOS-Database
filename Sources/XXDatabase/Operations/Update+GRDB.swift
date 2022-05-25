import GRDB
import XXModels

extension Database {
  @discardableResult
  public func update<Record>(
    _ record: Record
  ) throws -> Record
  where Record: MutablePersistableRecord {
    try queue.sync {
      try writer.write { db in
        try record.update(db)
        return record
      }
    }
  }

  public func update<Record>() -> Update<Record>
  where Record: MutablePersistableRecord {
    Update { record in
      try update(record)
    }
  }
}
