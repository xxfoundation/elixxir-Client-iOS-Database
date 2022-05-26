import Combine

/// Model update operation publisher
///
/// - Takes existing `Model` that should be updated.
/// - Returns publisher that emits updated `Model`.
/// - Updated `Model` could be different from the input one (e.g. updated timestamp).
/// - The publisher completes immediately after emitting value.
/// - The publisher completes with `Error` on operation failure.
public struct UpdatePublisher<Model> {
  /// Instantiate operation
  ///
  /// - Parameters:
  ///   - run: Closure that performs the operation
  public init(run: @escaping (Model) -> AnyPublisher<Model, Error>) {
    self.run = run
  }

  /// Closure that returns operation publisher
  public var run: (Model) -> AnyPublisher<Model, Error>

  public func callAsFunction(_ model: Model) -> AnyPublisher<Model, Error> {
    run(model)
  }
}
