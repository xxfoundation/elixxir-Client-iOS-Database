import Combine

/// Model delete operation publisher
///
/// - Takes existing `Model` that should be deleted.
/// - Returns publisher that emits `true` on success (otherwise `false`).
/// - The publisher completes immediately after emitting value.
/// - The publisher completes with `Error` on operation failure.
public struct DeletePublisher<Model> {
  /// Instantiate operation
  ///
  /// - Parameters:
  ///   - run: Closure that returns operation publisher
  public init(run: @escaping (Model) -> AnyPublisher<Bool, Error>) {
    self.run = run
  }

  /// Closure that returns operation publisher
  public var run: (Model) -> AnyPublisher<Bool, Error>

  public func callAsFunction(_ model: Model) -> AnyPublisher<Bool, Error> {
    run(model)
  }
}
