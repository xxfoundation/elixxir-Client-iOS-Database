import Foundation
import GRDB
import XXModels

extension Update {
  static func grdb<Record>(
    _ writer: DatabaseWriter,
    _ queue: DispatchQueue
  ) -> Update<Record>
  where Record: MutablePersistableRecord {
    Update<Record> { record in
      try queue.sync {
        try writer.write { db in
          try record.update(db)
          return record
        }
      }
    }
  }
}
