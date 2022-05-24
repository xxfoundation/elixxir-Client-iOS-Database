import Combine

public struct FetchPublisher<Model, Query> {
  public init(run: @escaping (Query) -> AnyPublisher<[Model], Error>) {
    self.run = run
  }

  public var run: (Query) -> AnyPublisher<[Model], Error>

  public func callAsFunction(_ query: Query) -> AnyPublisher<[Model], Error> {
    run(query)
  }
}
