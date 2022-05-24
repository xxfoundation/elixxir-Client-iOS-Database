import GRDB
import XXModels

extension Database {
  public func save<Record>() -> Save<Record>
  where Record: MutablePersistableRecord {
    Save { record in
      try queue.sync {
        try writer.write { db in
          try record.saved(db)
        }
      }
    }
  }
}
