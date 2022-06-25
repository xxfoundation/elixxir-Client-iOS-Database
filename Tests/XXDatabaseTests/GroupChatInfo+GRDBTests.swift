import CustomDump
import XCTest
import XXModels
@testable import XXDatabase

final class GroupChatInfoGRDBTests: XCTestCase {
  var db: Database!

  override func setUp() async throws {
    db = try Database.inMemory()
  }

  override func tearDown() async throws {
    db = nil
  }

  func testFetching() throws {
    // Mock up contacts:

    let contactA = try db.saveContact(.stub("A"))
    let contactB = try db.saveContact(.stub("B"))
    let contactC = try db.saveContact(.stub("C"))
    let contactD = try db.saveContact(.stub("D"))

    // Mock up groups:

    let groupA = try db.saveGroup(.stub(
      "A",
      leaderId: contactA.id,
      createdAt: .stub(1),
      authStatus: .participating
    ))

    try db.saveGroupMember(GroupMember(groupId: groupA.id, contactId: contactA.id))
    try db.saveGroupMember(GroupMember(groupId: groupA.id, contactId: contactB.id))
    try db.saveGroupMember(GroupMember(groupId: groupA.id, contactId: contactC.id))

    let groupB = try db.saveGroup(.stub(
      "B",
      leaderId: contactB.id,
      createdAt: .stub(2),
      authStatus: .hidden
    ))

    try db.saveGroupMember(GroupMember(groupId: groupB.id, contactId: contactB.id))
    try db.saveGroupMember(GroupMember(groupId: groupB.id, contactId: contactC.id))
    try db.saveGroupMember(GroupMember(groupId: groupB.id, contactId: contactD.id))

    try db.saveGroup(.stub(
      "C",
      leaderId: contactC.id,
      createdAt: .stub(3),
      authStatus: .participating
    ))

    // Mock up messages in group A:

    try db.saveMessage(.stub(
      from: contactA,
      to: groupA,
      at: 1,
      isUnread: true
    ))

    try db.saveMessage(.stub(
      from: contactB,
      to: groupA,
      at: 2,
      isUnread: false
    ))

    try db.saveMessage(.stub(
      from: contactC,
      to: groupA,
      at: 3,
      isUnread: true
    ))

    let lastMessage_inGroupA_at4 = try db.saveMessage(.stub(
      from: contactB,
      to: groupA,
      at: 4,
      isUnread: false
    ))

    // Mock up messages in group B:

    try db.saveMessage(.stub(
      from: contactD,
      to: groupB,
      at: 5,
      isUnread: false
    ))

    try db.saveMessage(.stub(
      from: contactC,
      to: groupB,
      at: 6,
      isUnread: false
    ))

    let lastMessage_inGroupB_at7 = try db.saveMessage(.stub(
      from: contactB,
      to: groupB,
      at: 7,
      isUnread: false
    ))

    // Fetch group chat infos:

    XCTAssertNoDifference(
      try db.fetchGroupChatInfos(GroupChatInfo.Query()),
      [
        GroupChatInfo(
          group: groupB,
          lastMessage: lastMessage_inGroupB_at7,
          unreadCount: 0
        ),
        GroupChatInfo(
          group: groupA,
          lastMessage: lastMessage_inGroupA_at4,
          unreadCount: 2
        ),
      ]
    )

    // Fetch group chat infos for groups with `participating` auth status:

    XCTAssertNoDifference(
      try db.fetchGroupChatInfos(GroupChatInfo.Query(
        authStatus: [.participating]
      )),
      [
        GroupChatInfo(
          group: groupA,
          lastMessage: lastMessage_inGroupA_at4,
          unreadCount: 2
        ),
      ]
    )
  }
}
