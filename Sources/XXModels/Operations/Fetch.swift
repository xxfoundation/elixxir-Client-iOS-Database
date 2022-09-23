/// Model fetch operation
///
/// - Takes `Query` that should be used for the fetch.
/// - Returns array of fetched `Model`s.
/// - Throws: `Error` on operation failure.
public struct Fetch<Model, Query> {
  /// Instantiate operation
  ///
  /// - Parameters:
  ///   - run: Closure that performs the operation
  public init(run: @escaping (Query) throws -> [Model]) {
    self.run = run
  }

  /// Closure that performs the operation
  public var run: (Query) throws -> [Model]

  @discardableResult
  public func callAsFunction(_ query: Query) throws -> [Model] {
    try run(query)
  }
}

#if DEBUG
import XCTestDynamicOverlay

extension Fetch {
  public static func unimplemented<Model, Query>() -> Fetch<Model, Query> {
    Fetch<Model, Query>(run: XCTUnimplemented("\(Self.self)"))
  }
}
#endif
