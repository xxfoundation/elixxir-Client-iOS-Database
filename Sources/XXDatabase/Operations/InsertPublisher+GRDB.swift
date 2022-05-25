import Combine
import GRDB
import XXModels

extension Database {
  public func insertPublisher<Record>(
    _ record: Record
  ) -> AnyPublisher<Record, Error>
  where Record: MutablePersistableRecord {
    writer.writePublisher(
      receiveOn: queue,
      updates: record.inserted(_:)
    )
    .eraseToAnyPublisher()
  }

  public func insertPublisher<Record>() -> InsertPublisher<Record>
  where Record: MutablePersistableRecord {
    InsertPublisher { record in
      insertPublisher(record)
    }
  }
}
