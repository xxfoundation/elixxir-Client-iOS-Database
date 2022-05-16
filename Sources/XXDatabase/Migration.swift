import GRDB

public struct Migration {
  var id: String
  var migrate: (GRDB.Database) throws -> Void
}

extension Sequence where Element == Migration {
  public static var all: [Migration] {[
    Migration(id: "0") { db in
      try db.create(table: ContactRecord.databaseTableName) { t in
        t.column(ContactRecord.Columns.id.name, .blob).notNull()
        t.column(ContactRecord.Columns.marshaled.name, .blob).notNull()
        t.column(ContactRecord.Columns.username.name, .text)
        t.column(ContactRecord.Columns.email.name, .text)
        t.column(ContactRecord.Columns.phone.name, .text)
        t.column(ContactRecord.Columns.nickname.name, .text)
        t.primaryKey([ContactRecord.Columns.id.name])
      }
    }
  ]}
}
