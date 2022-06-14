import Combine
import Foundation
import GRDB
import XXModels

extension FetchPublisher {
  static func grdb<Record, Query, Request, Decoder>(
    _ writer: DatabaseWriter,
    _ queue: DispatchQueue,
    _ request: @escaping (Query) -> Request
  ) -> FetchPublisher<Record, Query>
  where Record: FetchableRecord,
        Request: FetchRequest,
        Request.RowDecoder == Decoder
  {
    FetchPublisher<Record, Query> { query in
      ValueObservation
        .tracking { try Record.fetchAll($0, request(query)) }
        .publisher(in: writer, scheduling: .async(onQueue: queue))
        .eraseToAnyPublisher()
    }
  }
}
