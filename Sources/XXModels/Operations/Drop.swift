/// Database drop operation
///
/// - Removes all record from database
/// - Drops schema
/// - Removes migrations history
public struct Drop {
  /// Instantiate operation
  ///
  /// - Parameter run: Closure that performs the operation
  public init(run: @escaping () throws -> Void) {
    self.run = run
  }

  /// Closure that performs the operation
  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }
}

#if DEBUG
extension Drop {
  public static let failing = Drop { fatalError() }
}
#endif
