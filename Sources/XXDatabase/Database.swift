import Combine
import Foundation
import GRDB

public struct Database {
  let writer: DatabaseWriter
  let queue: DispatchQueue

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
    let db = Database(
      writer: DatabaseQueue(),
      queue: DispatchQueue(label: "XXDatabase")
    )
    try db.migrate(migrations)
    return db
  }

  public func fetch<Record, Request, Decoder>(
    _ request: Request
  ) throws -> [Record]
  where Record: FetchableRecord,
        Request: FetchRequest,
        Request.RowDecoder == Decoder
  {
    try queue.sync {
      try writer.read { db in
        try Record.fetchAll(db, request)
      }
    }
  }

  public func fetch<Record, Query, Request, Decoder>(
    _ request: @escaping (Query) -> Request
  ) -> (Query) throws -> [Record]
  where Record: FetchableRecord,
        Request: FetchRequest,
        Request.RowDecoder == Decoder
  {
    { query in
      try fetch(request(query))
    }
  }

  public func fetchPublisher<Record, Request, Decoder>(
    _ request: Request
  ) -> AnyPublisher<[Record], Error>
  where Record: FetchableRecord,
        Request: FetchRequest,
        Request.RowDecoder == Decoder
  {
    ValueObservation
      .tracking { try Record.fetchAll($0, request) }
      .publisher(in: writer, scheduling: .async(onQueue: queue))
      .eraseToAnyPublisher()
  }

  public func fetchPublisher<Record, Query, Request, Decoder>(
    _ request: @escaping (Query) -> Request
  ) -> (Query) -> AnyPublisher<[Record], Error>
  where Record: FetchableRecord,
        Request: FetchRequest,
        Request.RowDecoder == Decoder
  {
    { query in
      fetchPublisher(request(query))
    }
  }

  @discardableResult
  public func insert<Record>(
    _ record: Record
  ) throws -> Record
  where Record: MutablePersistableRecord {
    try queue.sync {
      try writer.write { db in
        try record.inserted(db)
      }
    }
  }

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

  @discardableResult
  public func update<Record>(
    _ record: Record
  ) throws -> Record
  where Record: MutablePersistableRecord {
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

  @discardableResult
  public func save<Record>(
    _ record: Record
  ) throws -> Record
  where Record: MutablePersistableRecord {
    try queue.sync {
      try writer.write { db in
        try record.saved(db)
      }
    }
  }

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

  @discardableResult
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
