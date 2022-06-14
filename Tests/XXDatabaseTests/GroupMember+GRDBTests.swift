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
    let save: GroupMember.Save = db.saveGroupMember
    let delete: GroupMember.Delete = db.deleteGroupMember

    func fetchAll() throws -> [GroupMember] {
      try writer.read(GroupMember.fetchAll(_:))
    }

    let contactA = Contact.stub("A")
    let contactB = Contact.stub("B")
    let contactC = Contact.stub("C")
    let groupA = Group.stub("A", leaderId: contactA.id, createdAt: .stub(1))
    let groupB = Group.stub("B", leaderId: contactB.id, createdAt: .stub(2))

    try db.saveContact(contactA)
    try db.saveContact(contactB)
    try db.saveContact(contactC)
    try db.saveGroup(groupA)
    try db.saveGroup(groupB)

    // Add contacts A and B as members of group A:

    _ = try save(GroupMember(groupId: groupA.id, contactId: contactA.id))
    _ = try save(GroupMember(groupId: groupA.id, contactId: contactB.id))

    XCTAssertNoDifference(try fetchAll(), [
      GroupMember(groupId: groupA.id, contactId: contactA.id),
      GroupMember(groupId: groupA.id, contactId: contactB.id),
    ])

    // Add contacts B and C as members of group B:

    _ = try save(GroupMember(groupId: groupB.id, contactId: contactB.id))
    _ = try save(GroupMember(groupId: groupB.id, contactId: contactC.id))

    XCTAssertNoDifference(try fetchAll(), [
      GroupMember(groupId: groupA.id, contactId: contactA.id),
      GroupMember(groupId: groupA.id, contactId: contactB.id),
      GroupMember(groupId: groupB.id, contactId: contactB.id),
      GroupMember(groupId: groupB.id, contactId: contactC.id),
    ])

    // Delete contact C from group B:

    _ = try delete(GroupMember(groupId: groupB.id, contactId: contactC.id))

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
