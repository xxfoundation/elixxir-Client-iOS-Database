import CustomDump
import XCTest
import XXModels
@testable import XXDatabase

final class FileTransferGRDBTests: XCTestCase {
  var db: Database!

  override func setUp() async throws {
    db = try Database.inMemory()
  }

  override func tearDown() async throws {
    db = nil
  }

  func testBasicOperations() throws {
    // Mock up contacts:

    let contactA = try db.saveContact(.stub("A"))
    let contactB = try db.saveContact(.stub("B"))

    // Save transfers:

    let transfer1 = try db.saveFileTransfer(.stub(
      "T1",
      contact: contactA,
      isIncoming: true,
      at: 1
    ))

    let transfer2 = try db.saveFileTransfer(.stub(
      "T2",
      contact: contactA,
      isIncoming: false,
      at: 2
    ))

    let transfer3 = try db.saveFileTransfer(.stub(
      "T3",
      contact: contactB,
      isIncoming: true,
      at: 3
    ))

    let transfer4 = try db.saveFileTransfer(.stub(
      "T4",
      contact: contactB,
      isIncoming: false,
      at: 4
    ))

    // Fetch transfers:

    XCTAssertNoDifference(
      try db.fetchFileTransfers(.init()),
      [transfer4, transfer3, transfer2, transfer1]
    )

    XCTAssertNoDifference(
      try db.fetchFileTransfers(.init(sortBy: .createdAt())),
      [transfer1, transfer2, transfer3, transfer4]
    )

    XCTAssertNoDifference(
      try db.fetchFileTransfers(.init(id: [transfer2.id])),
      [transfer2]
    )

    XCTAssertNoDifference(
      try db.fetchFileTransfers(.init(id: [transfer2.id, transfer3.id])),
      [transfer3, transfer2]
    )

    XCTAssertNoDifference(
      try db.fetchFileTransfers(.init(contactId: contactB.id)),
      [transfer4, transfer3]
    )

    XCTAssertNoDifference(
      try db.fetchFileTransfers(.init(isIncoming: true)),
      [transfer3, transfer1]
    )

    XCTAssertNoDifference(
      try db.fetchFileTransfers(.init(isIncoming: false)),
      [transfer4, transfer2]
    )

    // Delete transfer:

    try db.deleteFileTransfer(transfer3)

    XCTAssertNoDifference(
      try db.fetchFileTransfers(.init()),
      [transfer4, transfer2, transfer1]
    )

    // Update transfer:

    var updatedTransfer2 = transfer2
    updatedTransfer2.name = "Updated"
    try db.saveFileTransfer(updatedTransfer2)

    XCTAssertNoDifference(
      try db.fetchFileTransfers(.init()),
      [transfer4, updatedTransfer2, transfer1]
    )
  }
}
