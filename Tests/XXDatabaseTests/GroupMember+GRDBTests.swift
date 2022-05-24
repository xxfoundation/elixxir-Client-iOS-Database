import CustomDump
import XCTest
import XXModels
@testable import XXDatabase

final class GroupMemberGRDBTests: XCTestCase {
  var db: Database!

  override func setUp() async throws {
    db = try Database.inMemory()
  }

  override func tearDown() async throws {
    db = nil
  }

  func testDatabaseOperations() throws {
    let save: GroupMember.Save = db.save()
    let delete: GroupMember.Delete = db.delete()

    func fetchAll() throws -> [GroupMember] {
      try db.fetch(GroupMember.all())
    }

    let contactA = Contact.stub("A")
    let contactB = Contact.stub("B")
    let contactC = Contact.stub("C")
    let groupA = Group.stub("A", leaderId: contactA.id, createdAt: .stub(1))
    let groupB = Group.stub("B", leaderId: contactB.id, createdAt: .stub(2))

    try db.save(contactA)
    try db.save(contactB)
    try db.save(contactC)
    try db.save(groupA)
    try db.save(groupB)

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

    try db.delete(contactB)

    XCTAssertNoDifference(try fetchAll(), [
      GroupMember(groupId: groupA.id, contactId: contactA.id),
    ])

    // Delete group B:

    try db.delete(groupB)

    XCTAssertNoDifference(try fetchAll(), [
      GroupMember(groupId: groupA.id, contactId: contactA.id),
    ])

    // Delete group A:

    try db.delete(groupA)

    XCTAssertNoDifference(try fetchAll(), [])
  }
}
