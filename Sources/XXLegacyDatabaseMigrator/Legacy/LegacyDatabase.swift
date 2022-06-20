import Foundation
import GRDB

/// Legacy database
///
/// Use this struct to instantiate legacy database from which the migration should be performed.
public struct LegacyDatabase {
  /// Instantiate legacy database using its default path on disk
  ///
  /// - Throws: Error when database can't be instantiated
  public init() throws {
    let fileManager = FileManager.default

    let appDocumentsPath = NSSearchPathForDirectoriesInDomains(
      .documentDirectory,
      .userDomainMask,
      true
    ).first!

    let appDbPath = appDocumentsPath.appending("/xxmessenger.sqlite")

    let appGroupDbPath = fileManager
      .containerURL(forSecurityApplicationGroupIdentifier: "group.elixxir.messenger")!
      .appendingPathComponent("database")
      .appendingPathExtension("sqlite")
      .path

    let appDbExists = fileManager.fileExists(atPath: appDbPath)
    let appGroupDbExists = fileManager.fileExists(atPath: appGroupDbPath)

    if appDbExists && !appGroupDbExists {
      try fileManager.moveItem(atPath: appDbPath, toPath: appGroupDbPath)
    }

    try fileManager.setAttributes(
      [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
      ofItemAtPath: appGroupDbPath
    )

    try self.init(path: appGroupDbPath)
  }

  /// Instantiate legacy database at provided path
  ///
  /// - Parameter path: Path to database stored on disk
  public init(path: String) throws {
    try self.init(writer: DatabaseQueue(path: path))
  }

  /// Instantiate legacy database with provided writer
  ///
  /// - Parameter writer: GRDB database writer
  /// - Throws: Error when database can't be instantiated
  public init(writer: DatabaseWriter) throws {
    var migrator = DatabaseMigrator()

    migrator.registerMigration("v1") { db in
      try db.create(table: Contact.databaseTableName, ifNotExists: true) { table in
        table.autoIncrementedPrimaryKey(Contact.Column.id.rawValue, onConflict: .replace)
        table.column(Contact.Column.photo.rawValue, .blob)
        table.column(Contact.Column.email.rawValue, .text)
        table.column(Contact.Column.phone.rawValue, .text)
        table.column(Contact.Column.nickname.rawValue, .text)
        table.column(Contact.Column.createdAt.rawValue, .datetime)
        table.column(Contact.Column.userId.rawValue, .blob).unique()
        table.column(Contact.Column.username.rawValue, .text).notNull()
        table.column(Contact.Column.status.rawValue, .integer).notNull()
        table.column(Contact.Column.marshaled.rawValue, .blob).notNull()
      }

      try db.create(table: Message.databaseTableName, ifNotExists: true) { table in
        table.autoIncrementedPrimaryKey(Message.Column.id.rawValue, onConflict: .replace)
        table.column(Message.Column.report.rawValue, .blob)
        table.column(Message.Column.uniqueId.rawValue, .blob)
        table.column(Message.Column.sender.rawValue, .blob).notNull()
        table.column(Message.Column.payload.rawValue, .text).notNull()
        table.column(Message.Column.receiver.rawValue, .blob).notNull()
        table.column(Message.Column.roundURL.rawValue, .text)
        table.column(Message.Column.status.rawValue, .integer).notNull()
        table.column(Message.Column.unread.rawValue, .boolean).notNull()
        table.column(Message.Column.timestamp.rawValue, .integer).notNull()
      }

      try db.create(table: Group.databaseTableName, ifNotExists: true) { table in
        table.autoIncrementedPrimaryKey(Group.Column.id.rawValue, onConflict: .replace)
        table.column(Group.Column.groupId.rawValue, .blob).unique()
        table.column(Group.Column.name.rawValue, .text).notNull()
        table.column(Group.Column.leader.rawValue, .blob).notNull()
        table.column(Group.Column.serialize.rawValue, .blob).notNull()
        table.column(Group.Column.accepted.rawValue, .boolean).notNull()
      }

      try db.create(table: GroupMember.databaseTableName, ifNotExists: true) { table in
        table.autoIncrementedPrimaryKey(GroupMember.Column.id.rawValue, onConflict: .replace)
        table.column(GroupMember.Column.userId.rawValue, .blob).notNull()
        table.column(GroupMember.Column.username.rawValue, .text).notNull()
        table.column(GroupMember.Column.photo.rawValue, .blob)
        table.column(GroupMember.Column.status.rawValue, .integer).notNull()
        table.column(GroupMember.Column.groupId.rawValue, .blob).notNull()
          .references(
            Group.databaseTableName,
            column: Group.Column.groupId.rawValue,
            onDelete: .cascade,
            deferred: true
          )
      }

      try db.create(table: GroupMessage.databaseTableName, ifNotExists: true) { table in
        table.autoIncrementedPrimaryKey(GroupMessage.Column.id.rawValue, onConflict: .replace)
        table.column(GroupMessage.Column.uniqueId.rawValue, .blob)
        table.column(GroupMessage.Column.roundId.rawValue, .integer)
        table.column(GroupMessage.Column.groupId.rawValue, .blob).notNull()
        table.column(GroupMessage.Column.sender.rawValue, .blob).notNull()
        table.column(GroupMessage.Column.roundURL.rawValue, .text)
        table.column(GroupMessage.Column.payload.rawValue, .text).notNull()
        table.column(GroupMessage.Column.status.rawValue, .integer).notNull()
        table.column(GroupMessage.Column.unread.rawValue, .boolean).notNull()
        table.column(GroupMessage.Column.timestamp.rawValue, .integer).notNull()
      }

      try db.create(table: FileTransfer.databaseTableName, ifNotExists: true) { table in
        table.autoIncrementedPrimaryKey(FileTransfer.Column.id.rawValue, onConflict: .replace)
        table.column(FileTransfer.Column.tid.rawValue, .blob).notNull()
        table.column(FileTransfer.Column.contact.rawValue, .blob).notNull()
        table.column(FileTransfer.Column.fileName.rawValue, .text).notNull()
        table.column(FileTransfer.Column.fileType.rawValue, .text).notNull()
        table.column(FileTransfer.Column.isIncoming.rawValue, .boolean).notNull()
      }
    }

    migrator.registerMigration("v1: Updating contact/group requests UI") { db in
      try db.create(table: "temp_\(Group.databaseTableName)") { table in
        table.autoIncrementedPrimaryKey(Group.Column.id.rawValue, onConflict: .replace)
        table.column(Group.Column.groupId.rawValue, .blob).unique()
        table.column(Group.Column.name.rawValue, .text).notNull()
        table.column(Group.Column.leader.rawValue, .blob).notNull()
        table.column(Group.Column.serialize.rawValue, .blob).notNull()
        table.column(Group.Column.status.rawValue, .integer).notNull()
        table.column(Group.Column.createdAt.rawValue, .datetime).notNull()
      }

      let oldRows = try Row.fetchCursor(db, sql: "SELECT * FROM \(Group.databaseTableName)")
      while let row = try oldRows.next() {
        let status: Group.Status

        if row["accepted"] == true {
          status = .participating
        } else {
          status = .pending
        }

        try db.execute(
          sql: """
          INSERT INTO temp_\(Group.databaseTableName)
          (id, groupId, name, leader, serialize, status, createdAt)
          VALUES (?, ?, ?, ?, ?, ?, ?)
          """,
          arguments: [
            row["id"],
            row["groupId"],
            row["name"],
            row["leader"],
            row["serialize"],
            status.rawValue,
            Date()
          ]
        )
      }

      try db.drop(table: Group.databaseTableName)
      try db.rename(table: "temp_\(Group.databaseTableName)", to: Group.databaseTableName)
    }

    migrator.registerMigration("v2") { db in
      try db.alter(table: Contact.databaseTableName) { table in
        table.add(column: Contact.Column.isRecent.rawValue, .boolean)
      }

      try Contact.updateAll(db, Contact.Column.isRecent.set(to: false))
    }

    try migrator.migrate(writer)
    self.writer = writer
  }

  let writer: DatabaseWriter
}
