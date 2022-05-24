import GRDB
import XXModels

extension Database {
  public func insert<Record>() -> Insert<Record>
  where Record: MutablePersistableRecord {
    Insert { record in
      try queue.sync {
        try writer.write { db in
          try record.inserted(db)
        }
      }
    }
  }
}
