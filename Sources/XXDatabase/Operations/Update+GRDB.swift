import GRDB
import XXModels

extension Database {
  public func update<Record>() -> Update<Record>
  where Record: MutablePersistableRecord {
    Update { record in
      try queue.sync {
        try writer.write { db in
          try record.update(db)
          return record
        }
      }
    }
  }
}
