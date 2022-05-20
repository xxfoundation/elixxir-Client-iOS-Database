import CustomDump
import XCTest
import XXModels
@testable import XXDatabase

final class GroupTests: XCTestCase {
  var db: Database!

  override func setUp() async throws {
    db = try Database.inMemory()
  }

  override func tearDown() async throws {
    db = nil
  }

  func testSavingAndDeleting() throws {
    let save: Group.Save = db.save(_:)
    let delete: Group.Delete = db.delete(_:)

    let contactA = Contact.stub(1)
    let contactB = Contact.stub(2)

    _ = try db.save(contactA)
    _ = try db.save(contactB)

    func fetchAll() throws -> [Group] {
      try db.fetch(Group.order(Group.Column.name))
    }

    // Save new groups A, B, and C:

    let groupA = Group.stub(1, leaderId: contactA.id)
    let groupB = Group.stub(2, leaderId: contactB.id)
    let groupC = Group.stub(3, leaderId: contactA.id)

    XCTAssertNoDifference(try save(groupA), groupA)
    XCTAssertNoDifference(try save(groupB), groupB)
    XCTAssertNoDifference(try save(groupC), groupC)

    XCTAssertNoDifference(
      try fetchAll(),
      [groupA, groupB, groupC]
    )

    // Delete group A:

    XCTAssertNoDifference(try delete(groupA), true)

    XCTAssertNoDifference(
      try fetchAll(),
      [groupB, groupC]
    )

    // Delete contact A - the leader of group A and C:

    _ = try db.delete(contactA)

    XCTAssertNoDifference(
      try fetchAll(),
      [groupB]
    )
  }
}
