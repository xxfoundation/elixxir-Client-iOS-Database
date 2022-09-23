/// Model save operation
///
/// - Takes `Model` that should be saved.
/// - If the model already exists, it will be updated.
/// - If the model does not yet exists, it will be inserted.
/// - Returns saved `Model`.
/// - Saved `Model` could be different from the input one (e.g. unique id could be set).
/// - Throws: `Error` on operation failure.
public struct Save<Model> {
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

#if DEBUG
import XCTestDynamicOverlay

extension Save {
  public static func unimplemented<Model>() -> Save<Model> {
    Save<Model>(run: XCTUnimplemented("\(Self.self)"))
  }
}
#endif
