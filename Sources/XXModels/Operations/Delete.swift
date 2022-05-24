public struct Delete<Model> {
  public init(run: @escaping (Model) throws -> Bool) {
    self.run = run
  }

  public var run: (Model) throws -> Bool

  @discardableResult
  public func callAsFunction(_ model: Model) throws -> Bool {
    try run(model)
  }
}
