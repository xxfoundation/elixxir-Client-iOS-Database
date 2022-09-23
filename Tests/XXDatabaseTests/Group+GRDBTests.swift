import CustomDump
import GRDB
import XCTest
import XXModels
@testable import XXDatabase

final class GroupGRDBTests: XCTestCase {
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

  func testSavingAndDeleting() throws {
    func fetchAll() throws -> [Group] {
      try writer.read { try Group.order(Group.Column.name).fetchAll($0) }
    }

    // Mock up contacts:

    let contactA = Contact.stub("A")
    let contactB = Contact.stub("B")

    try db.saveContact(contactA)
    try db.saveContact(contactB)

    // Save new groups A, B, and C:

    let groupA = Group.stub("A", leaderId: contactA.id, createdAt: .stub(1))
    let groupB = Group.stub("B", leaderId: contactB.id, createdAt: .stub(2))
    let groupC = Group.stub("C", leaderId: contactA.id, createdAt: .stub(3))

    XCTAssertNoDifference(try db.saveGroup(groupA), groupA)
    XCTAssertNoDifference(try db.saveGroup(groupB), groupB)
    XCTAssertNoDifference(try db.saveGroup(groupC), groupC)

    XCTAssertNoDifference(
      try fetchAll(),
      [groupA, groupB, groupC]
    )

    // Delete group A:

    XCTAssertNoDifference(try db.deleteGroup(groupA), true)

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
    // Mock up contacts:

    let contactA = try db.saveContact(.stub("A"))
    let contactB = try db.saveContact(.stub("B"))

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

    XCTAssertNoDifference(
      try db.fetchGroups(Group.Query()),
      [groupC, groupB, groupA]
    )

    XCTAssertNoDifference(
      try db.fetchGroups(Group.Query(sortBy: .createdAt())),
      [groupA, groupB, groupC]
    )

    XCTAssertNoDifference(
      try db.fetchGroups(Group.Query(sortBy: .createdAt(desc: true))),
      [groupC, groupB, groupA]
    )

    // Fetch groups with given id:

    XCTAssertNoDifference(
      try db.fetchGroups(Group.Query(id: [groupB.id])),
      [groupB]
    )

    XCTAssertNoDifference(
      try db.fetchGroups(Group.Query(id: [groupA.id, groupC.id])),
      [groupC, groupA]
    )

    // Fetch groups with messages:

    XCTAssertNoDifference(
      try db.fetchGroups(Group.Query(withMessages: true, sortBy: .createdAt())),
      [groupA]
    )

    // Fetch groups without messages:

    XCTAssertNoDifference(
      try db.fetchGroups(Group.Query(withMessages: false, sortBy: .createdAt())),
      [groupB, groupC]
    )

    // Fetch groups with auth status `participating` or `pending`:

    XCTAssertNoDifference(
      try db.fetchGroups(Group.Query(
        authStatus: [.participating, .pending],
        sortBy: .createdAt()
      )),
      [groupA, groupB]
    )
  }

  func testFetchingWithBlockedLeaders() throws {
    // Mock up contacts:

    let contactA = try db.saveContact(.stub("A").withBlocked(false))
    let contactB = try db.saveContact(.stub("B").withBlocked(true))

    // Mock up groups:

    let groupA = try db.saveGroup(.stub(
      "A",
      leaderId: contactA.id,
      createdAt: .stub(1)
    ))

    let groupB = try db.saveGroup(.stub(
      "B",
      leaderId: contactB.id,
      createdAt: .stub(2)
    ))

    // Fetch groups with blocked leaders:

    XCTAssertNoDifference(try db.fetchGroups(.init(isLeaderBlocked: true)), [
      groupB,
    ])

    // Fetch groups with non-blocked leaders:

    XCTAssertNoDifference(try db.fetchGroups(.init(isLeaderBlocked: false)), [
      groupA,
    ])

    // Fetch groups regardless leader's blocked status:

    XCTAssertNoDifference(try db.fetchGroups(.init(isLeaderBlocked: nil)), [
      groupB,
      groupA,
    ])
  }

  func testFetchingWithBannedLeaders() throws {
    // Mock up contacts:

    let contactA = try db.saveContact(.stub("A").withBanned(false))
    let contactB = try db.saveContact(.stub("B").withBanned(true))

    // Mock up groups:

    let groupA = try db.saveGroup(.stub(
      "A",
      leaderId: contactA.id,
      createdAt: .stub(1)
    ))

    let groupB = try db.saveGroup(.stub(
      "B",
      leaderId: contactB.id,
      createdAt: .stub(2)
    ))

    // Fetch groups with banned leaders:

    XCTAssertNoDifference(try db.fetchGroups(.init(isLeaderBanned: true)), [
      groupB,
    ])

    // Fetch groups with non-banned leaders:

    XCTAssertNoDifference(try db.fetchGroups(.init(isLeaderBanned: false)), [
      groupA,
    ])

    // Fetch groups regardless leader's banned status:

    XCTAssertNoDifference(try db.fetchGroups(.init(isLeaderBanned: nil)), [
      groupB,
      groupA,
    ])
  }
}
