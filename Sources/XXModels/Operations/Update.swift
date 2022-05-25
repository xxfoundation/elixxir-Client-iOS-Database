public struct Update<Model> {
  public init(run: @escaping (Model) throws -> Model) {
    self.run = run
  }

  public var run: (Model) throws -> Model

  @discardableResult
  public func callAsFunction(_ model: Model) throws -> Model {
    try run(model)
  }
}
