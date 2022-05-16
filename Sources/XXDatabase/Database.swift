import Combine
import Foundation
import GRDB
import XXModels

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
}

extension Database {
  func fetch<Model, Query, Order, Record>(
    request: @escaping (Query, Order) -> QueryInterfaceRequest<Record>,
    toModel: @escaping (Record) -> Model
  ) -> (Query, Order) throws -> [Model]
  where Record: FetchableRecord {
    { [writer, queue] query, order in
      try queue.sync {
        try writer.read { db in
          try Record
            .fetchAll(db, request(query, order))
            .map(toModel)
        }
      }
    }
  }

  func fetchPublisher<Model, Query, Order, Record>(
    request: @escaping (Query, Order) -> QueryInterfaceRequest<Record>,
    toModel: @escaping (Record) -> Model
  ) -> (Query, Order) -> AnyPublisher<[Model], Error>
  where Record: FetchableRecord {
    { [writer, queue] query, order in
      ValueObservation
        .tracking(request(query, order).fetchAll(_:))
        .publisher(
          in: writer,
          scheduling: .async(onQueue: queue)
        )
        .map { $0.map(toModel) }
        .eraseToAnyPublisher()
    }
  }

  func insert<Model, Record>(
    toRecord: @escaping (Model) -> Record,
    toModel: @escaping (Record) -> Model
  ) -> (Model) throws -> Model
  where Record: PersistableRecord {
    { [writer, queue] model in
      try queue.sync {
        try writer.write { db in
          toModel(try toRecord(model).inserted(db))
        }
      }
    }
  }

  func insertPublisher<Model, Record>(
    toRecord: @escaping (Model) -> Record,
    toModel: @escaping (Record) -> Model
  ) -> (Model) -> AnyPublisher<Model, Error>
  where Record: PersistableRecord {
    { [writer, queue] model in
      writer
        .writePublisher(
          receiveOn: queue,
          updates: toRecord(model).inserted(_:)
        )
        .map(toModel)
        .eraseToAnyPublisher()
    }
  }

  func update<Model, Record>(
    toRecord: @escaping (Model) -> Record,
    toModel: @escaping (Record) -> Model
  ) -> (Model) throws -> Model
  where Record: PersistableRecord {
    { [writer, queue] model in
      try queue.sync {
        try writer.write { db in
          try toRecord(model).update(db)
          return model
        }
      }
    }
  }

  func updatePublisher<Model, Record>(
    toRecord: @escaping (Model) -> Record,
    toModel: @escaping (Record) -> Model
  ) -> (Model) -> AnyPublisher<Model, Error>
  where Record: PersistableRecord {
    { [writer, queue] model in
      writer
        .writePublisher(
          receiveOn: queue,
          updates: { db in
            let record = toRecord(model)
            try record.update(db)
            return record
          }
        )
        .map(toModel)
        .eraseToAnyPublisher()
    }
  }

  func delete<Model, Record>(
    toRecord: @escaping (Model) -> Record
  ) -> (Model) throws -> Bool
  where Record: PersistableRecord {
    { [writer, queue] model in
      try queue.sync {
        try writer.write { db in
          try toRecord(model).delete(db)
        }
      }
    }
  }

  func deletePublisher<Model, Record>(
    toRecord: @escaping (Model) -> Record
  ) -> (Model) -> AnyPublisher<Bool, Error>
  where Record: PersistableRecord {
    { [writer, queue] model in
      writer
        .writePublisher(
          receiveOn: queue,
          updates: { try toRecord(model).delete($0) }
        )
        .eraseToAnyPublisher()
    }
  }
}
