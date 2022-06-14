import Foundation
import GRDB
import XXModels

extension Save {
  static func grdb<Record>(
    _ writer: DatabaseWriter,
    _ queue: DispatchQueue
  ) -> Save<Record>
  where Record: MutablePersistableRecord {
    Save<Record> { record in
      try queue.sync {
        try writer.write { db in
          try record.saved(db)
        }
      }
    }
  }
}
