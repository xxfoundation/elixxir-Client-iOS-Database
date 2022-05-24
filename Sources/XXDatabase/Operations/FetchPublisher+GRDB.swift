import GRDB
import XXModels

extension Database {
  public func fetchPublisher<Record, Query, Request, Decoder>(
    _ request: @escaping (Query) -> Request
  ) -> FetchPublisher<Record, Query>
  where Record: FetchableRecord,
        Request: FetchRequest,
        Request.RowDecoder == Decoder
  {
    FetchPublisher { query in
      ValueObservation
        .tracking { try Record.fetchAll($0, request(query)) }
        .publisher(in: writer, scheduling: .async(onQueue: queue))
        .eraseToAnyPublisher()
    }
  }
}
