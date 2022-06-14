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
    let fetch: GroupInfo.Fetch = db.fetchGroupInfos

    let contactA = Contact.stub("A")
    let contactB = Contact.stub("B")
    let contactC = Contact.stub("C")

    let groupA = Group.stub("A", leaderId: contactA.id, createdAt: .stub(1))
    let groupB = Group.stub("B", leaderId: contactB.id, createdAt: .stub(2))
    let groupC = Group.stub("C", leaderId: contactC.id, createdAt: .stub(3))

    try db.insertContact(contactA)
    try db.insertContact(contactB)
    try db.insertContact(contactC)
    try db.saveGroup(groupA)
    try db.saveGroup(groupB)
    try db.saveGroup(groupC)

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

    try db.saveGroupMember(GroupMember(groupId: groupA.id, contactId: contactB.id))
    try db.saveGroupMember(GroupMember(groupId: groupA.id, contactId: contactC.id))
    try db.saveGroupMember(GroupMember(groupId: groupB.id, contactId: contactA.id))
    try db.saveGroupMember(GroupMember(groupId: groupB.id, contactId: contactB.id))
    try db.saveGroupMember(GroupMember(groupId: groupC.id, contactId: contactA.id))
    try db.saveGroupMember(GroupMember(groupId: groupC.id, contactId: contactC.id))

    XCTAssertNoDifference(try fetch(GroupInfo.Query(sortBy: .groupName())), [
      GroupInfo(group: groupA, leader: contactA, members: [contactB, contactC]),
      GroupInfo(group: groupB, leader: contactB, members: [contactA, contactB]),
      GroupInfo(group: groupC, leader: contactC, members: [contactA, contactC]),
    ])

    // Delete contact B (member of groups A and B and leader of group B):

    try db.deleteContact(contactB)

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
