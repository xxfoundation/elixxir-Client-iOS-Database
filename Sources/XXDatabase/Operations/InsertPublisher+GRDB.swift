import GRDB
import XXModels

extension Database {
  public func insertPublisher<Record>() -> InsertPublisher<Record>
  where Record: MutablePersistableRecord {
    InsertPublisher { record in
      writer.writePublisher(
        receiveOn: queue,
        updates: record.inserted(_:)
      )
      .eraseToAnyPublisher()
    }
  }
}
