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

    let contactA = Contact.stub("A")
    let contactB = Contact.stub("B")

    _ = try db.save(contactA)
    _ = try db.save(contactB)

    func fetchAll() throws -> [Group] {
      try db.fetch(Group.order(Group.Column.name))
    }

    // Save new groups A, B, and C:

    let groupA = Group.stub("A", leaderId: contactA.id, createdAt: .stub(1))
    let groupB = Group.stub("B", leaderId: contactB.id, createdAt: .stub(2))
    let groupC = Group.stub("C", leaderId: contactA.id, createdAt: .stub(3))

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

  func testFetching() throws {
    let fetch: Group.Fetch = db.fetch(Group.request(_:))

    // Mock up contacts:

    let contactA = try db.insert(Contact.stub("A"))
    let contactB = try db.insert(Contact.stub("B"))

    // Mock up groups:

    let groupA = try db.insert(Group.stub(
      "A",
      leaderId: contactA.id,
      createdAt: .stub(1)
    ))

    let groupB = try db.insert(Group.stub(
      "B",
      leaderId: contactB.id,
      createdAt: .stub(2)
    ))

    let groupC = try db.insert(Group.stub(
      "C",
      leaderId: contactB.id,
      createdAt: .stub(3)
    ))

    // Mock up messages:

    _ = try db.insert(Message.stub(
      from: contactA,
      to: groupA,
      at: 1
    ))

    // Fetch all groups:

    XCTAssertNoDifference(try fetch(Group.Query(sortBy: .createdAt())), [
      groupA, groupB, groupC,
    ])

    XCTAssertNoDifference(try fetch(Group.Query(sortBy: .createdAt(desc: true))), [
      groupC, groupB, groupA,
    ])

    // Fetch groups with messages:

    XCTAssertNoDifference(try fetch(Group.Query(withMessages: true, sortBy: .createdAt())), [
      groupA,
    ])

    // Fetch groups without messages:

    XCTAssertNoDifference(try fetch(Group.Query(withMessages: false, sortBy: .createdAt())), [
      groupB, groupC,
    ])
  }
}
