/// Model insert operation
///
/// - Takes new `Model` that should be inserted.
/// - Returns inserted `Model`.
/// - Inserted `Model` could be different from the input one (e.g. unique id could be set).
/// - Throws `Error` on operation failure.
public struct Insert<Model> {
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

extension Insert {
  public static func failing<Model>() -> Insert<Model> {
    Insert<Model> { _ in fatalError() }
  }
}
