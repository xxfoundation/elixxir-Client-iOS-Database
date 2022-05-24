import GRDB
import XXModels

extension Database {
  public func savePublisher<Record>() -> SavePublisher<Record>
  where Record: MutablePersistableRecord {
    SavePublisher { record in
      writer.writePublisher(
        receiveOn: queue,
        updates: record.saved(_:)
      )
      .eraseToAnyPublisher()
    }
  }
}
