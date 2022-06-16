import Foundation
import GRDB
import XXModels

extension DeleteMany {
  static func grdb<Record, Query>(
    _ writer: DatabaseWriter,
    _ queue: DispatchQueue,
    _ request: @escaping (Query) -> QueryInterfaceRequest<Record>
  ) -> DeleteMany<Record, Query>
  where Record: MutablePersistableRecord {
    DeleteMany<Record, Query> { query in
      try queue.sync {
        try writer.write { db in
          try request(query).deleteAll(db)
        }
      }
    }
  }
}
