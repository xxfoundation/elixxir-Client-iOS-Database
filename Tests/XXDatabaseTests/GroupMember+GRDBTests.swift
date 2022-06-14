import CustomDump
import GRDB
import XCTest
import XXModels
@testable import XXDatabase

final class GroupMemberGRDBTests: XCTestCase {
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

  func testDatabaseOperations() throws {
    func fetchAll() throws -> [GroupMember] {
      try writer.read(GroupMember.fetchAll(_:))
    }

    // Mock up contacts and groups:

    let contactA = try db.saveContact(.stub("A"))
    let contactB = try db.saveContact(.stub("B"))
    let contactC = try db.saveContact(.stub("C"))
    let groupA = try db.saveGroup(.stub("A", leaderId: contactA.id, createdAt: .stub(1)))
    let groupB = try db.saveGroup(.stub("B", leaderId: contactB.id, createdAt: .stub(2)))

    // Add contacts A and B as members of group A:

    try db.saveGroupMember(GroupMember(groupId: groupA.id, contactId: contactA.id))
    try db.saveGroupMember(GroupMember(groupId: groupA.id, contactId: contactB.id))

    XCTAssertNoDifference(try fetchAll(), [
      GroupMember(groupId: groupA.id, contactId: contactA.id),
      GroupMember(groupId: groupA.id, contactId: contactB.id),
    ])

    // Add contacts B and C as members of group B:

    try db.saveGroupMember(GroupMember(groupId: groupB.id, contactId: contactB.id))
    try db.saveGroupMember(GroupMember(groupId: groupB.id, contactId: contactC.id))

    XCTAssertNoDifference(try fetchAll(), [
      GroupMember(groupId: groupA.id, contactId: contactA.id),
      GroupMember(groupId: groupA.id, contactId: contactB.id),
      GroupMember(groupId: groupB.id, contactId: contactB.id),
      GroupMember(groupId: groupB.id, contactId: contactC.id),
    ])

    // Delete contact C from group B:

    try db.deleteGroupMember(GroupMember(groupId: groupB.id, contactId: contactC.id))

    XCTAssertNoDifference(try fetchAll(), [
      GroupMember(groupId: groupA.id, contactId: contactA.id),
      GroupMember(groupId: groupA.id, contactId: contactB.id),
      GroupMember(groupId: groupB.id, contactId: contactB.id),
    ])

    // Delete contact B (belonging to groups A and B):

    try db.deleteContact(contactB)

    XCTAssertNoDifference(try fetchAll(), [
      GroupMember(groupId: groupA.id, contactId: contactA.id),
    ])

    // Delete group B:

    try db.deleteGroup(groupB)

    XCTAssertNoDifference(try fetchAll(), [
      GroupMember(groupId: groupA.id, contactId: contactA.id),
    ])

    // Delete group A:

    try db.deleteGroup(groupA)

    XCTAssertNoDifference(try fetchAll(), [])
  }
}
