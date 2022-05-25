import GRDB
import XXModels

extension Database {
  public func fetch<Record, Request, Decoder>(
    _ request: Request
  ) throws -> [Record]
  where Record: FetchableRecord,
        Request: FetchRequest,
        Request.RowDecoder == Decoder
  {
    try queue.sync {
      try writer.read { db in
        try Record.fetchAll(db, request)
      }
    }
  }

  public func fetch<Record, Query, Request, Decoder>(
    _ request: @escaping (Query) -> Request
  ) -> Fetch<Record, Query>
  where Record: FetchableRecord,
        Request: FetchRequest,
        Request.RowDecoder == Decoder
  {
    Fetch { query in
      try fetch(request(query))
    }
  }
}
