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

  func testDatabaseOperations() throws {
    let save: Group.Save = db.save(_:)
    let fetch: Group.Fetch = db.fetch(Group.request(_:_:))
    let delete: Group.Delete = db.delete(_:)

    let contactA = Contact.stub(1)
    let contactB = Contact.stub(2)
    let groupA = Group.stub(1, leaderId: contactA.id)
    let groupB = Group.stub(2, leaderId: contactB.id)
    let groupC = Group.stub(3, leaderId: contactA.id)

    _ = try db.save(contactA)
    _ = try db.save(contactB)

    // Insert groups A, B, and C:

    XCTAssertNoDifference(try save(groupA), groupA)
    XCTAssertNoDifference(try save(groupB), groupB)
    XCTAssertNoDifference(try save(groupC), groupC)

    XCTAssertNoDifference(
      try fetch(.all, .name()),
      [groupA, groupB, groupC]
    )

    XCTAssertNoDifference(
      try fetch(.all, .name(desc: true)),
      [groupC, groupB, groupA]
    )

    // Delete group A:

    XCTAssertNoDifference(try delete(groupA), true)

    XCTAssertNoDifference(
      try fetch(.all, .name()),
      [groupB, groupC]
    )

    // Delete contact A - the leader of group A and C:

    _ = try db.delete(contactA)

    XCTAssertNoDifference(
      try fetch(.all, .name()),
      [groupB]
    )
  }
}
