import Combine

public struct UpdatePublisher<Model> {
  public init(run: @escaping (Model) -> AnyPublisher<Model, Error>) {
    self.run = run
  }

  public var run: (Model) -> AnyPublisher<Model, Error>

  public func callAsFunction(_ model: Model) -> AnyPublisher<Model, Error> {
    run(model)
  }
}
