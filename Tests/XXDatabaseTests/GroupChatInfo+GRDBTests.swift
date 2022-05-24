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
    let fetch: GroupChatInfo.Fetch = db.fetch(GroupChatInfo.request(_:))

    // Mock up contacts:

    let contactA = try db.insert(Contact.stub("A"))
    let contactB = try db.insert(Contact.stub("B"))
    let contactC = try db.insert(Contact.stub("C"))
    let contactD = try db.insert(Contact.stub("D"))

    // Mock up groups:

    let groupA = try db.insert(Group.stub(
      "A",
      leaderId: contactA.id,
      createdAt: .stub(1)
    ))

    try db.insert(GroupMember(groupId: groupA.id, contactId: contactA.id))
    try db.insert(GroupMember(groupId: groupA.id, contactId: contactB.id))
    try db.insert(GroupMember(groupId: groupA.id, contactId: contactC.id))

    let groupB = try db.insert(Group.stub(
      "B",
      leaderId: contactB.id,
      createdAt: .stub(2)
    ))

    try db.insert(GroupMember(groupId: groupB.id, contactId: contactB.id))
    try db.insert(GroupMember(groupId: groupB.id, contactId: contactC.id))
    try db.insert(GroupMember(groupId: groupB.id, contactId: contactD.id))

    try db.insert(Group.stub(
      "C",
      leaderId: contactC.id,
      createdAt: .stub(3)
    ))

    // Mock up messages in group A:

    try db.insert(Message.stub(
      from: contactA,
      to: groupA,
      at: 1,
      isUnread: true
    ))

    try db.insert(Message.stub(
      from: contactB,
      to: groupA,
      at: 2,
      isUnread: false
    ))

    try db.insert(Message.stub(
      from: contactC,
      to: groupA,
      at: 3,
      isUnread: true
    ))

    let lastMessage_inGroupA_at4 = try db.insert(Message.stub(
      from: contactB,
      to: groupA,
      at: 4,
      isUnread: false
    ))

    // Mock up messages in group B:

    try db.insert(Message.stub(
      from: contactD,
      to: groupB,
      at: 5,
      isUnread: false
    ))

    try db.insert(Message.stub(
      from: contactC,
      to: groupB,
      at: 6,
      isUnread: false
    ))

    let lastMessage_inGroupB_at7 = try db.insert(Message.stub(
      from: contactB,
      to: groupB,
      at: 7,
      isUnread: false
    ))

    // Fetch group chat infos:

    XCTAssertNoDifference(try fetch(GroupChatInfo.Query()), [
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
    ])
  }
}
