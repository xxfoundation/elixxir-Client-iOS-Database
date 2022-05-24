import GRDB
import XXModels

extension Database {
  public func delete<Record>() -> Delete<Record>
  where Record: PersistableRecord {
    Delete { record in
      try queue.sync {
        try writer.write(record.delete(_:))
      }
    }
  }
}
