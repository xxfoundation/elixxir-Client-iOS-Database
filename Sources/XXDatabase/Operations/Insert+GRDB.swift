import Foundation
import GRDB
import XXModels

extension Insert {
  static func grdb<Record>(
    _ writer: DatabaseWriter,
    _ queue: DispatchQueue
  ) -> Insert<Record>
  where Record: MutablePersistableRecord {
    Insert<Record> { record in
      try queue.sync {
        try writer.write { db in
          try record.inserted(db)
        }
      }
    }
  }
}
