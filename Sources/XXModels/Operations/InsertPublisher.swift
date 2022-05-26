import Combine

/// Model insert operation publisher
///
/// - Takes new `Model` that should be inserted.
/// - Returns publisher that emits inserted `Model` on success.
/// - Inserted `Model` could be different from the input one (e.g. unique id could be set).
/// - The publisher completes immediately after emitting value.
/// - The publisher completes with `Error` on operation failure.
public struct InsertPublisher<Model> {
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
