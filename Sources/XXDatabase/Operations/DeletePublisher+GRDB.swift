import GRDB
import XXModels

extension Database {
  public func deletePublisher<Record>() -> DeletePublisher<Record>
  where Record: PersistableRecord {
    DeletePublisher { record in
      writer.writePublisher(
        receiveOn: queue,
        updates: record.delete(_:)
      )
      .eraseToAnyPublisher()
    }
  }
}
