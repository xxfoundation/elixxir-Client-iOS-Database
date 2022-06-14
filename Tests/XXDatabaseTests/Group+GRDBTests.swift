import CustomDump
import GRDB
import XCTest
import XXModels
@testable import XXDatabase

final class GroupGRDBTests: XCTestCase {
  var db: XXModels.Database!
  var writer: DatabaseWriter!

  override func setUp() async throws {
    writer = DatabaseQueue()
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

  func testSavingAndDeleting() throws {
    let save: Group.Save = db.saveGroup
    let delete: Group.Delete = db.deleteGroup

    let contactA = Contact.stub("A")
    let contactB = Contact.stub("B")

    try db.saveContact(contactA)
    try db.saveContact(contactB)

    func fetchAll() throws -> [Group] {
      try writer.read { try Group.order(Group.Column.name).fetchAll($0) }
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

    try db.deleteContact(contactA)

    XCTAssertNoDifference(
      try fetchAll(),
      [groupB]
    )
  }

  func testFetching() throws {
    let fetch: Group.Fetch = db.fetchGroups

    // Mock up contacts:

    let contactA = try db.insertContact(.stub("A"))
    let contactB = try db.insertContact(.stub("B"))

    // Mock up groups:

    let groupA = try db.saveGroup(.stub(
      "A",
      leaderId: contactA.id,
      createdAt: .stub(1),
      authStatus: .participating
    ))

    let groupB = try db.saveGroup(.stub(
      "B",
      leaderId: contactB.id,
      createdAt: .stub(2),
      authStatus: .pending
    ))

    let groupC = try db.saveGroup(.stub(
      "C",
      leaderId: contactB.id,
      createdAt: .stub(3),
      authStatus: .hidden
    ))

    // Mock up messages:

    try db.saveMessage(.stub(
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

    // Fetch groups with auth status `participating` or `pending`:

    XCTAssertNoDifference(try fetch(Group.Query(
      authStatus: [.participating, .pending],
      sortBy: .createdAt()
    )), [
      groupA, groupB,
    ])
  }
}
