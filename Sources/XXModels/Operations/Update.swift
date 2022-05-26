/// Model update operation
///
/// - Takes existing `Model` that should be updated.
/// - Returns updated `Model`.
/// - Updated `Model` could be different from the input one (e.g. updated timestamp).
/// - Throws `Error` on operation failure.
public struct Update<Model> {
  /// Instantiate operation
  ///
  /// - Parameters:
  ///   - run: Closure that performs the operation
  public init(run: @escaping (Model) throws -> Model) {
    self.run = run
  }

  /// Closure that performs the operation
  public var run: (Model) throws -> Model

  @discardableResult
  public func callAsFunction(_ model: Model) throws -> Model {
    try run(model)
  }
}
