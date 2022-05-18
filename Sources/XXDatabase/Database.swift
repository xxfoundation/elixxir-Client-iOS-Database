import Combine
import Foundation
import GRDB

public struct Database {
  let writer: DatabaseWriter
  let queue = DispatchQueue(label: "XXDatabase")

  private func migrate(_ migrations: [Migration]) throws {
    var migrator = DatabaseMigrator()
    migrations.forEach { migration in
      migrator.registerMigration(migration.id, migrate: migration.migrate)
    }
    try migrator.migrate(writer)
  }
}

extension Database {
  public static func inMemory(migrations: [Migration] = .all) throws -> Database {
    let writer = DatabaseQueue()
    let db = Database(writer: writer)
    try db.migrate(migrations)
    return db
  }

  public func fetch<Record, RowDecoder>(
    _ request: QueryInterfaceRequest<RowDecoder>
  ) throws -> [Record]
  where Record: FetchableRecord {
    try queue.sync {
      try writer.read { db in
        try Record.fetchAll(db, request)
      }
    }
  }

  public func fetch<Record, RowDecoder, Query, Order>(
    _ request: @escaping (Query, Order) -> QueryInterfaceRequest<RowDecoder>
  ) -> (Query, Order) throws -> [Record]
  where Record: FetchableRecord {
    { query, order in
      try fetch(request(query, order))
    }
  }

  public func fetchPublisher<Record, RowDecoder>(
    _ request: QueryInterfaceRequest<RowDecoder>
  ) -> AnyPublisher<[Record], Error>
  where Record: FetchableRecord {
    ValueObservation
      .tracking { try Record.fetchAll($0, request) }
      .publisher(in: writer, scheduling: .async(onQueue: queue))
      .eraseToAnyPublisher()
  }

  public func fetchPublisher<Record, RowDecoder, Query, Order>(
    _ request: @escaping (Query, Order) -> QueryInterfaceRequest<RowDecoder>
  ) -> (Query, Order) -> AnyPublisher<[Record], Error>
  where Record: FetchableRecord {
    { query, order in
      fetchPublisher(request(query, order))
    }
  }

  public func insert<Record>(
    _ record: Record
  ) throws -> Record
  where Record: PersistableRecord {
    try queue.sync {
      try writer.write { db in
        try record.inserted(db)
      }
    }
  }

  public func insertPublisher<Record>(
    _ record: Record
  ) -> AnyPublisher<Record, Error>
  where Record: PersistableRecord {
    writer.writePublisher(
      receiveOn: queue,
      updates: record.inserted(_:)
    )
    .eraseToAnyPublisher()
  }

  public func update<Record>(
    _ record: Record
  ) throws -> Record
  where Record: PersistableRecord {
    try queue.sync {
      try writer.write { db in
        try record.update(db)
        return record
      }
    }
  }

  public func updatePublisher<Record>(
    _ record: Record
  ) -> AnyPublisher<Record, Error>
  where Record: PersistableRecord {
    writer.writePublisher(
      receiveOn: queue,
      updates: { db in
        try record.update(db)
        return record
      }
    )
    .eraseToAnyPublisher()
  }

  public func delete<Record>(
    _ record: Record
  ) throws -> Bool
  where Record: PersistableRecord {
    try queue.sync {
      try writer.write(record.delete(_:))
    }
  }

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
}
