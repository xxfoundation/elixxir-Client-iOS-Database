import GRDB
import XXModels

extension Database {
  public func updatePublisher<Record>() -> UpdatePublisher<Record>
  where Record: MutablePersistableRecord {
    UpdatePublisher { record in
      writer.writePublisher(
        receiveOn: queue,
        updates: { db in
          try record.update(db)
          return record
        }
      )
      .eraseToAnyPublisher()
    }
  }
}
