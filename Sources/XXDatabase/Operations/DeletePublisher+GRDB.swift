import Combine
import GRDB
import XXModels

extension Database {
  public func deletePublisher<Record>(
    _ record: Record
  ) -> AnyPublisher<Bool, Error>
  where Record: PersistableRecord {
    writer.writePublisher(
      receiveOn: queue,
      updates: record.delete(_:)
    )
    .eraseToAnyPublisher()
  }

  public func deletePublisher<Record>() -> DeletePublisher<Record>
  where Record: PersistableRecord {
    DeletePublisher { record in
      deletePublisher(record)
    }
  }
}
