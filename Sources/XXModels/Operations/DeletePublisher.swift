import Combine

public struct DeletePublisher<Model> {
  public init(run: @escaping (Model) -> AnyPublisher<Bool, Error>) {
    self.run = run
  }

  public var run: (Model) -> AnyPublisher<Bool, Error>

  public func callAsFunction(_ model: Model) -> AnyPublisher<Bool, Error> {
    run(model)
  }
}
