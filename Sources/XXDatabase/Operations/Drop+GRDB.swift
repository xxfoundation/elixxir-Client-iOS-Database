import Foundation
import GRDB
import XXModels

extension Drop {
  static func grdb(
    _ writer: DatabaseWriter,
    _ queue: DispatchQueue
  ) -> Drop {
    Drop {
      try queue.sync {
        try writer.write { db in
          try Message.deleteAll(db)
          try FileTransfer.deleteAll(db)
          try GroupMember.deleteAll(db)
          try Group.deleteAll(db)
          try Contact.deleteAll(db)
          try db.drop(table: Message.databaseTableName)
          try db.drop(table: FileTransfer.databaseTableName)
          try db.drop(table: GroupMember.databaseTableName)
          try db.drop(table: Group.databaseTableName)
          try db.drop(table: Contact.databaseTableName)
          try db.execute(sql: "DELETE FROM grdb_migrations")
        }
      }
    }
  }
}
