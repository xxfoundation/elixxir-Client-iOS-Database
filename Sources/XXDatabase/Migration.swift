import GRDB

public struct Migration {
  var id: String
  var migrate: (GRDB.Database) throws -> Void
}

extension Sequence where Element == Migration {
  public static var all: [Migration] {[
    Migration(id: "0") { db in
      try db.create(table: "contacts") { t in
        t.column("id", .blob).notNull().primaryKey()
        t.column("marshaled", .blob)
        t.column("username", .text)
        t.column("email", .text)
        t.column("phone", .text)
        t.column("nickname", .text)
      }

      try db.create(table: "groups") { t in
        t.column("id", .blob).notNull().primaryKey()
        t.column("name", .text).notNull()
        t.column("leaderId", .blob).notNull().references("contacts", column: "id")
        t.column("createdAt", .datetime).notNull()
      }

      try db.create(table: "groupMembers") { t in
        t.column("groupId").notNull().references("groups", column: "id")
        t.column("contactId").notNull().references("contacts", column: "id")
      }
    }
  ]}
}
