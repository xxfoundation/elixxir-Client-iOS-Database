/// Model delete operation
///
/// - Takes existing `Model` that should be deleted.
/// - Returns `true` on success. Otherwise returns `false`.
/// - Throws: `Error` on operation failure.
public struct Delete<Model> {
  /// Instantiate operation
  ///
  /// - Parameters:
  ///   - run: Closure that performs the operation
  public init(run: @escaping (Model) throws -> Bool) {
    self.run = run
  }

  /// Closure that performs the operation
  public var run: (Model) throws -> Bool

  @discardableResult
  public func callAsFunction(_ model: Model) throws -> Bool {
    try run(model)
  }
}

#if DEBUG
import XCTestDynamicOverlay

extension Delete {
  public static func failing<Model>() -> Delete<Model> {
    Delete<Model> { _ in fatalError() }
  }

  public static func unimplemented<Model>() -> Delete<Model> {
    Delete<Model>(run: XCTUnimplemented("\(Self.self)"))
  }
}
#endif
