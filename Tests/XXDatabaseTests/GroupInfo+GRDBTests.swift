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
    // Mock up contacts and groups:

    let contactA = try db.saveContact(.stub("A"))
    let contactB = try db.saveContact(.stub("B"))
    let contactC = try db.saveContact(.stub("C"))
    let groupA = try db.saveGroup(.stub("A", leaderId: contactA.id, createdAt: .stub(1)))
    let groupB = try db.saveGroup(.stub("B", leaderId: contactB.id, createdAt: .stub(2)))
    let groupC = try db.saveGroup(.stub("C", leaderId: contactC.id, createdAt: .stub(3)))

    // Fetch group infos:

    XCTAssertNoDifference(try db.fetchGroupInfos(GroupInfo.Query(sortBy: .groupName())), [
      GroupInfo(group: groupA, leader: contactA, members: []),
      GroupInfo(group: groupB, leader: contactB, members: []),
      GroupInfo(group: groupC, leader: contactC, members: []),
    ])

    XCTAssertNoDifference(try db.fetchGroupInfos(GroupInfo.Query(sortBy: .groupName(desc: true))), [
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

    XCTAssertNoDifference(try db.fetchGroupInfos(GroupInfo.Query(sortBy: .groupName())), [
      GroupInfo(group: groupA, leader: contactA, members: [contactB, contactC]),
      GroupInfo(group: groupB, leader: contactB, members: [contactA, contactB]),
      GroupInfo(group: groupC, leader: contactC, members: [contactA, contactC]),
    ])

    // Delete contact B (member of groups A and B and leader of group B):

    try db.deleteContact(contactB)

    XCTAssertNoDifference(try db.fetchGroupInfos(GroupInfo.Query(sortBy: .groupName())), [
      GroupInfo(group: groupA, leader: contactA, members: [contactC]),
      GroupInfo(group: groupC, leader: contactC, members: [contactA, contactC]),
    ])

    // Fetch group C:

    XCTAssertNoDifference(
      try db.fetchGroupInfos(GroupInfo.Query(groupId: groupC.id, sortBy: .groupName())),
      [GroupInfo(group: groupC, leader: contactC, members: [contactA, contactC])]
    )
  }
}
