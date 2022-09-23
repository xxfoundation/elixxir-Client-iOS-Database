import Combine

/// Model fetch operation publisher
///
/// - Takes `Query` that should be used for the fetch.
/// - Returns publisher that emits array of `Model`s whenever they change.
/// - The publisher completes with `Error` on operation failure.
public struct FetchPublisher<Model, Query> {
  /// Instantiate operation
  ///
  /// - Parameters:
  ///   - run: Closure that returns operation publisher
  public init(run: @escaping (Query) -> AnyPublisher<[Model], Error>) {
    self.run = run
  }

  /// Closure that returns operation publisher
  public var run: (Query) -> AnyPublisher<[Model], Error>

  public func callAsFunction(_ query: Query) -> AnyPublisher<[Model], Error> {
    run(query)
  }
}

#if DEBUG
import XCTestDynamicOverlay

extension FetchPublisher {
  public static func unimplemented<Model, Query>() -> FetchPublisher<Model, Query> {
    FetchPublisher<Model, Query>(
      run: XCTUnimplemented("\(Self.self)", placeholder: Empty().eraseToAnyPublisher())
    )
  }
}
#endif
