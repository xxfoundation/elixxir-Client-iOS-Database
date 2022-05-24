import CustomDump
import XCTest
import XXModels
@testable import XXDatabase

final class GroupInfoGRDBTests: XCTestCase {
  var db: Database!

  override func setUp() async throws {
    db = try Database.inMemory()
  }

  override func tearDown() async throws {
    db = nil
  }

  func testFetchingGroupInfo() throws {
    let fetch: GroupInfo.Fetch = db.fetch(GroupInfo.request(_:))

    let contactA = Contact.stub("A")
    let contactB = Contact.stub("B")
    let contactC = Contact.stub("C")

    let groupA = Group.stub("A", leaderId: contactA.id, createdAt: .stub(1))
    let groupB = Group.stub("B", leaderId: contactB.id, createdAt: .stub(2))
    let groupC = Group.stub("C", leaderId: contactC.id, createdAt: .stub(3))

    try db.insert(contactA)
    try db.insert(contactB)
    try db.insert(contactC)
    try db.insert(groupA)
    try db.insert(groupB)
    try db.insert(groupC)

    // Fetch group infos:

    XCTAssertNoDifference(try fetch(GroupInfo.Query(sortBy: .groupName())), [
      GroupInfo(group: groupA, leader: contactA, members: []),
      GroupInfo(group: groupB, leader: contactB, members: []),
      GroupInfo(group: groupC, leader: contactC, members: []),
    ])

    XCTAssertNoDifference(try fetch(GroupInfo.Query(sortBy: .groupName(desc: true))), [
      GroupInfo(group: groupC, leader: contactC, members: []),
      GroupInfo(group: groupB, leader: contactB, members: []),
      GroupInfo(group: groupA, leader: contactA, members: []),
    ])

    // Add members to groups:

    try db.insert(GroupMember(groupId: groupA.id, contactId: contactB.id))
    try db.insert(GroupMember(groupId: groupA.id, contactId: contactC.id))
    try db.insert(GroupMember(groupId: groupB.id, contactId: contactA.id))
    try db.insert(GroupMember(groupId: groupB.id, contactId: contactB.id))
    try db.insert(GroupMember(groupId: groupC.id, contactId: contactA.id))
    try db.insert(GroupMember(groupId: groupC.id, contactId: contactC.id))

    XCTAssertNoDifference(try fetch(GroupInfo.Query(sortBy: .groupName())), [
      GroupInfo(group: groupA, leader: contactA, members: [contactB, contactC]),
      GroupInfo(group: groupB, leader: contactB, members: [contactA, contactB]),
      GroupInfo(group: groupC, leader: contactC, members: [contactA, contactC]),
    ])

    // Delete contact B (member of groups A and B and leader of group B):

    try db.delete(contactB)

    XCTAssertNoDifference(try fetch(GroupInfo.Query(sortBy: .groupName())), [
      GroupInfo(group: groupA, leader: contactA, members: [contactC]),
      GroupInfo(group: groupC, leader: contactC, members: [contactA, contactC]),
    ])

    // Fetch group C:

    XCTAssertNoDifference(
      try fetch(GroupInfo.Query(groupId: groupC.id, sortBy: .groupName())),
      [GroupInfo(group: groupC, leader: contactC, members: [contactA, contactC])]
    )
  }
}
