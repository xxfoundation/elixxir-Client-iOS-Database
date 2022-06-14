import Foundation
import GRDB
import XXModels

extension Delete {
  static func grdb<Record>(
    _ writer: DatabaseWriter,
    _ queue: DispatchQueue
  ) -> Delete<Record>
  where Record: MutablePersistableRecord {
    Delete<Record> { record in
      try queue.sync {
        try writer.write(record.delete(_:))
      }
    }
  }
}
