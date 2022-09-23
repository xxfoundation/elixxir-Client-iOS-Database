import CustomDump
import GRDB
import XCTest
import XXModels
@testable import XXDatabase

final class DatabaseGRDBTests: XCTestCase {
  var db: XXModels.Database!
  var writer: DatabaseWriter!

  override func setUp() async throws {
    writer = try DatabaseQueue()
    db = try Database.grdb(
      writer: writer,
      queue: DispatchQueue(label: "XXDatabase"),
      migrations: .all
    )
  }

  override func tearDown() async throws {
    db = nil
    writer = nil
  }

  func testDrop() throws {
    func getTableNames() throws -> [String] {
      try writer.read { db in
        try Row.fetchAll(db, sql: """
        SELECT name FROM sqlite_schema
        WHERE type ='table'
          AND name != 'grdb_migrations'
          AND name NOT LIKE 'sqlite_%'
        """)
        .map { $0["name"]! }
      }
    }

    func getMigrationIds() throws -> [String] {
      try writer.read { db in
        try Row.fetchAll(db, sql: "SELECT identifier FROM grdb_migrations")
          .map { $0["identifier"]! }
      }
    }

    // Mock up data:

    let contactA = try db.saveContact(.stub("A"))
    let contactB = try db.saveContact(.stub("B"))
    let contactC = try db.saveContact(.stub("C"))

    let fileTransferA = try db.saveFileTransfer(
      .stub("A", contact: contactA, isIncoming: true, at: 1)
    )
    let fileTransferB = try db.saveFileTransfer(
      .stub("B", contact: contactB, isIncoming: false, at: 2)
    )
    let fileTransferC = try db.saveFileTransfer(
      .stub("C", contact: contactB, isIncoming: true, at: 3)
    )

    try db.saveMessage(.stub(from: contactA, to: contactB, at: 1))
    try db.saveMessage(.stub(from: contactB, to: contactA, at: 2, fileTransfer: fileTransferA))
    try db.saveMessage(.stub(from: contactA, to: contactB, at: 3))

    try db.saveMessage(.stub(from: contactA, to: contactC, at: 4))
    try db.saveMessage(.stub(from: contactC, to: contactA, at: 5))
    try db.saveMessage(.stub(from: contactA, to: contactC, at: 6))

    try db.saveMessage(.stub(from: contactB, to: contactC, at: 7))
    try db.saveMessage(.stub(from: contactC, to: contactB, at: 8, fileTransfer: fileTransferB))
    try db.saveMessage(.stub(from: contactB, to: contactC, at: 9))

    let groupA = try db.saveGroup(.stub("A", leaderId: contactA.id, createdAt: .stub(10)))
    try db.saveGroupMember(.init(groupId: groupA.id, contactId: contactA.id))
    try db.saveGroupMember(.init(groupId: groupA.id, contactId: contactB.id))

    try db.saveMessage(.stub(from: contactA, to: groupA, at: 11))
    try db.saveMessage(.stub(from: contactB, to: groupA, at: 12, fileTransfer: fileTransferC))
    try db.saveMessage(.stub(from: contactA, to: groupA, at: 13))

    let groupB = try db.saveGroup(.stub("B", leaderId: contactB.id, createdAt: .stub(14)))
    try db.saveGroupMember(.init(groupId: groupB.id, contactId: contactB.id))
    try db.saveGroupMember(.init(groupId: groupB.id, contactId: contactC.id))

    try db.saveMessage(.stub(from: contactB, to: groupB, at: 15))
    try db.saveMessage(.stub(from: contactC, to: groupB, at: 16))
    try db.saveMessage(.stub(from: contactB, to: groupB, at: 17))

    // Drop all data:

    try db.drop()

    XCTAssertNoDifference(try getTableNames(), [])
    XCTAssertNoDifference(try getMigrationIds(), [])
  }
}
