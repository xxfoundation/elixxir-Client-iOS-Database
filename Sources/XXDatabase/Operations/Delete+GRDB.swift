import GRDB
import XXModels

extension Database {
  @discardableResult
  public func delete<Record>(
    _ record: Record
  ) throws -> Bool
  where Record: PersistableRecord {
    try queue.sync {
      try writer.write(record.delete(_:))
    }
  }

  public func delete<Record>() -> Delete<Record>
  where Record: PersistableRecord {
    Delete { record in
      try delete(record)
    }
  }
}
