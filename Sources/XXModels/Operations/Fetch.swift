public struct Fetch<Model, Query> {
  public init(run: @escaping (Query) throws -> [Model]) {
    self.run = run
  }

  public var run: (Query) throws -> [Model]

  @discardableResult
  public func callAsFunction(_ query: Query) throws -> [Model] {
    try run(query)
  }
}
