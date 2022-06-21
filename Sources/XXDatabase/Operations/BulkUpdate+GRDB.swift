import Foundation
import GRDB
import XXModels

extension BulkUpdate {
  static func grdb<Record, Query, Assignments>(
    _ writer: DatabaseWriter,
    _ queue: DispatchQueue,
    _ request: @escaping (Query) -> QueryInterfaceRequest<Record>,
    _ columnAssignments: @escaping (Assignments) -> [ColumnAssignment]
  ) -> BulkUpdate<Query, Assignments>
  where Record: FetchableRecord {
    BulkUpdate<Query, Assignments> { query, assignments in
      try queue.sync {
        try writer.write { db in
          try request(query).updateAll(db, columnAssignments(assignments))
        }
      }
    }
  }
}
