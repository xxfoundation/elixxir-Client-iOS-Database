import Combine

/// Model save operation publisher
///
/// - Takes `Model` that should be saved.
/// - If the model already exists, it will be updated.
/// - If the model does not yet exists, it will be inserted.
/// - Returns publisher that emits saved `Model`.
/// - Saved `Model` could be different from the input one (e.g. unique id could be set).
/// - The publisher completes immediately after emitting value.
/// - The publisher completes with `Error` on operation failure.
public struct SavePublisher<Model> {
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
