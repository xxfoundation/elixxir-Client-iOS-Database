import Combine
import GRDB
import XXModels

extension Database {
  public func fetchPublisher<Record, Request, Decoder>(
    _ request: Request
  ) -> AnyPublisher<[Record], Error>
  where Record: FetchableRecord,
        Request: FetchRequest,
        Request.RowDecoder == Decoder
  {
    ValueObservation
      .tracking { try Record.fetchAll($0, request) }
      .publisher(in: writer, scheduling: .async(onQueue: queue))
      .eraseToAnyPublisher()
  }

  public func fetchPublisher<Record, Query, Request, Decoder>(
    _ request: @escaping (Query) -> Request
  ) -> FetchPublisher<Record, Query>
  where Record: FetchableRecord,
        Request: FetchRequest,
        Request.RowDecoder == Decoder
  {
    FetchPublisher { query in
      fetchPublisher(request(query))
    }
  }
}
