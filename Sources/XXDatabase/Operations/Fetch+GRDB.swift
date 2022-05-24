import GRDB
import XXModels

extension Database {
  public func fetch<Record, Query, Request, Decoder>(
    _ request: @escaping (Query) -> Request
  ) -> Fetch<Record, Query>
  where Record: FetchableRecord,
        Request: FetchRequest,
        Request.RowDecoder == Decoder
  {
    Fetch { query in
      try queue.sync {
        try writer.read { db in
          try Record.fetchAll(db, request(query))
        }
      }
    }
  }
}
