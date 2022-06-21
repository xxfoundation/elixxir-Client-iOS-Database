/// Models bulk update operation
///
/// - Updates all `Model` objects that matches provided query.
/// - Performs updates defined by provided `Assignments` struct.
/// - Returns number of updated objects.
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
