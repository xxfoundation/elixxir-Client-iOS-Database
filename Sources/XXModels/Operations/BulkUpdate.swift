/// Models bulk update operation
///
/// - Updates all `Model` objects that matches provided query.
/// - Performs updates defined by provided `Update` struct.
/// - Returns number of updated objects.
public struct BulkUpdate<Query, Update> {
  /// Instantiate operation
  ///
  /// - Parameter run: Closure that performs the operation
  public init(run: @escaping (Query, Update) throws -> Int) {
    self.run = run
  }

  /// Closure that performs the operation
  public var run: (Query, Update) throws -> Int

  @discardableResult
  public func callAsFunction(_ query: Query, _ update: Update) throws -> Int {
    try run(query, update)
  }
}

#if DEBUG
extension BulkUpdate {
  public static func failing<Query, Update>() -> BulkUpdate<Query, Update> {
    BulkUpdate<Query, Update> { _, _ in fatalError() }
  }
}
#endif
