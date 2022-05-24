import Combine
import GRDB
import XXModels

extension Database {
  public func savePublisher<Record>(
    _ record: Record
  ) -> AnyPublisher<Record, Error>
  where Record: MutablePersistableRecord {
    writer.writePublisher(
      receiveOn: queue,
      updates: record.saved(_:)
    )
    .eraseToAnyPublisher()
  }

  public func savePublisher<Record>() -> SavePublisher<Record>
  where Record: MutablePersistableRecord {
    SavePublisher { record in
      savePublisher(record)
    }
  }
}
