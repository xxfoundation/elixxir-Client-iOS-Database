/// Models delete operation
///
/// - Deletes all `Model` objects that matches provided `Query`.
/// - Returns number of deleted objects.
/// - Throws: `Error` on operation failure.
public struct DeleteMany<Model, Query> {
  /// Instantiate operation
  ///
  /// - Parameter run: Closure that performs the operation
  public init(run: @escaping (Query) throws -> Int) {
    self.run = run
  }

  /// Closure that performs the operation
  public var run: (Query) throws -> Int

  @discardableResult
  public func callAsFunction(_ query: Query) throws -> Int {
    try run(query)
  }
}

#if DEBUG
import XCTestDynamicOverlay

extension DeleteMany {
  public static func failing<Model, Query>() -> DeleteMany<Model, Query> {
    DeleteMany<Model, Query> { _ in fatalError() }
  }

  public static func unimplemented<Model>() -> DeleteMany<Model, Query> {
    DeleteMany<Model, Query>(run: XCTUnimplemented("\(Self.self)"))
  }
}
#endif
