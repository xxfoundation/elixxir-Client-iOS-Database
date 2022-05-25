import Combine
import GRDB
import XXModels

extension Database {
  public func updatePublisher<Record>(
    _ record: Record
  ) -> AnyPublisher<Record, Error>
  where Record: MutablePersistableRecord {
    writer.writePublisher(
      receiveOn: queue,
      updates: { db in
        try record.update(db)
        return record
      }
    )
    .eraseToAnyPublisher()
  }

  public func updatePublisher<Record>() -> UpdatePublisher<Record>
  where Record: MutablePersistableRecord {
    UpdatePublisher { record in
      updatePublisher(record)
    }
  }
}
