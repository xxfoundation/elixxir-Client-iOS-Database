import Foundation
import GRDB
import XXModels

extension Fetch {
  static func grdb<Record, Query, Request, Decoder>(
    _ writer: DatabaseWriter,
    _ queue: DispatchQueue,
    _ request: @escaping (Query) -> Request
  ) -> Fetch<Record, Query>
  where Record: FetchableRecord,
        Request: FetchRequest,
        Request.RowDecoder == Decoder
  {
    Fetch<Record, Query> { query in
      try queue.sync {
        try writer.read { db in
          try Record.fetchAll(db, request(query))
        }
      }
    }
  }
}
