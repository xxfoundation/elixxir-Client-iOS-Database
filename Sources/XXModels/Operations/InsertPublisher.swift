import Combine

public struct InsertPublisher<Model> {
  public init(run: @escaping (Model) -> AnyPublisher<Model, Error>) {
    self.run = run
  }

  public var run: (Model) -> AnyPublisher<Model, Error>

  public func callAsFunction(_ model: Model) -> AnyPublisher<Model, Error> {
    run(model)
  }
}
