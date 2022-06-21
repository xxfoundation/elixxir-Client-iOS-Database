import Foundation
import GRDB
import XXModels

extension BulkUpdate {
  static func grdb<Record, Query, Update>(
    _ writer: DatabaseWriter,
    _ queue: DispatchQueue,
    _ request: @escaping (Query) -> QueryInterfaceRequest<Record>,
    _ assignments: @escaping (Update) -> [ColumnAssignment]
  ) -> BulkUpdate<Query, Update>
  where Record: MutablePersistableRecord,
        Record: FetchableRecord
  {
    BulkUpdate<Query, Update> { query, update in
      try queue.sync {
        try writer.write { db in
          try request(query).updateAll(db, assignments(update))
        }
      }
    }
  }
}
