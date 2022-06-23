/// Models bulk update operation
///
/// - Updates all objects that matches provided `Query`.
/// - Performs updates defined by provided `Assignments`.
/// - Returns number of updated objects.
/// - Throws: `Error` on operation failure.
public struct BulkUpdate<Query, Assignments> {
  /// Instantiate operation
  ///
  /// - Parameter run: Closure that performs the operation
  public init(run: @escaping (Query, Assignments) throws -> Int) {
    self.run = run
  }

  /// Closure that performs the operation
  public var run: (Query, Assignments) throws -> Int

  @discardableResult
  public func callAsFunction(_ query: Query, _ update: Assignments) throws -> Int {
    try run(query, update)
  }
}

#if DEBUG
extension BulkUpdate {
  public static func failing<Query, Assignments>() -> BulkUpdate<Query, Assignments> {
    BulkUpdate<Query, Assignments> { _, _ in fatalError() }
  }
}
#endif
