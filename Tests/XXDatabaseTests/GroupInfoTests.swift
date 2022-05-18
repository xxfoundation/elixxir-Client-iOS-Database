import CustomDump
import XCTest
import XXModels
@testable import XXDatabase

final class GroupInfoTests: XCTestCase {
  var db: Database!

  override func setUp() async throws {
    db = try Database.inMemory()
  }

  override func tearDown() async throws {
    db = nil
  }

  func testDatabaseOperations() throws {
    let fetch: GroupInfo.Fetch = db.fetch(GroupInfo.request(_:_:))

    let contactA = Contact.stub(1)
    let contactB = Contact.stub(2)
    let contactC = Contact.stub(3)

    let groupA = Group.stub(1, leaderId: contactA.id)
    let groupB = Group.stub(2, leaderId: contactB.id)
    let groupC = Group.stub(3, leaderId: contactC.id)

    _ = try db.insert(contactA)
    _ = try db.insert(contactB)
    _ = try db.insert(contactC)
    _ = try db.insert(groupA)
    _ = try db.insert(groupB)
    _ = try db.insert(groupC)

    // Fetch group infos:

    XCTAssertNoDifference(try fetch(.all, .groupName()), [
      GroupInfo(group: groupA, leader: contactA, members: []),
      GroupInfo(group: groupB, leader: contactB, members: []),
      GroupInfo(group: groupC, leader: contactC, members: []),
    ])

    XCTAssertNoDifference(try fetch(.all, .groupName(desc: true)), [
      GroupInfo(group: groupC, leader: contactC, members: []),
      GroupInfo(group: groupB, leader: contactB, members: []),
      GroupInfo(group: groupA, leader: contactA, members: []),
    ])

    // Add members to groups:

    _ = try db.insert(GroupMember(groupId: groupA.id, contactId: contactB.id))
    _ = try db.insert(GroupMember(groupId: groupA.id, contactId: contactC.id))
    _ = try db.insert(GroupMember(groupId: groupB.id, contactId: contactA.id))
    _ = try db.insert(GroupMember(groupId: groupB.id, contactId: contactB.id))
    _ = try db.insert(GroupMember(groupId: groupC.id, contactId: contactA.id))
    _ = try db.insert(GroupMember(groupId: groupC.id, contactId: contactC.id))

    XCTAssertNoDifference(try fetch(.all, .groupName()), [
      GroupInfo(group: groupA, leader: contactA, members: [contactB, contactC]),
      GroupInfo(group: groupB, leader: contactB, members: [contactA, contactB]),
      GroupInfo(group: groupC, leader: contactC, members: [contactA, contactC]),
    ])

    // Delete contact B (member of groups A and B and leader of group B):

    _ = try db.delete(contactB)

    XCTAssertNoDifference(try fetch(.all, .groupName()), [
      GroupInfo(group: groupA, leader: contactA, members: [contactC]),
      GroupInfo(group: groupC, leader: contactC, members: [contactA, contactC]),
    ])
  }
}
