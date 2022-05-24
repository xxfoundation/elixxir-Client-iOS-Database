import CustomDump
import XCTest
import XXModels
@testable import XXDatabase

final class ChatInfoGRDBTests: XCTestCase {
  var db: Database!

  override func setUp() async throws {
    db = try Database.inMemory()
  }

  override func tearDown() async throws {
    db = nil
  }

  func testFetching() throws {
    let fetch: ChatInfo.Fetch = db.fetch()
    let fetchPublisher: ChatInfo.FetchPublisher = db.fetchPublisher()

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

    let groupC_createdAt5 = try db.insert(Group.stub(
      "C",
      leaderId: contactC.id,
      createdAt: .stub(5)
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

    // Mock up messages between contact A and B:

    try db.insert(Message.stub(
      from: contactA,
      to: contactB,
      at: 5,
      isUnread: true
    ))

    let lastMessage_betweenAandB_at6 = try db.insert(Message.stub(
      from: contactB,
      to: contactA,
      at: 6,
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

    // Mock up messages between contact B and C:

    try db.insert(Message.stub(
      from: contactB,
      to: contactC,
      at: 8,
      isUnread: false
    ))

    try db.insert(Message.stub(
      from: contactC,
      to: contactB,
      at: 9,
      isUnread: false
    ))

    // Mock up messages between contact A and C:

    try db.insert(Message.stub(
      from: contactA,
      to: contactC,
      at: 10,
      isUnread: true
    ))

    let lastMessage_betweenAandC_at11 = try db.insert(Message.stub(
      from: contactC,
      to: contactA,
      at: 11,
      isUnread: true
    ))

    // Fetch chat infos for user A:

    let expectedFetchResults: [ChatInfo] = [
      .contactChat(ContactChatInfo(
        contact: contactC,
        lastMessage: lastMessage_betweenAandC_at11,
        unreadCount: 2
      )),
      .groupChat(GroupChatInfo(
        group: groupB,
        lastMessage: lastMessage_inGroupB_at7,
        unreadCount: 0
      )),
      .contactChat(ContactChatInfo(
        contact: contactB,
        lastMessage: lastMessage_betweenAandB_at6,
        unreadCount: 1
      )),
      .group(groupC_createdAt5),
      .groupChat(GroupChatInfo(
        group: groupA,
        lastMessage: lastMessage_inGroupA_at4,
        unreadCount: 2
      )),
    ]

    XCTAssertNoDifference(
      try fetch(ChatInfo.Query(userId: contactA.id)),
      expectedFetchResults
    )

    // Subscribe to fetch publisher for user A:

    let fetchAssertion = PublisherAssertion<[ChatInfo], Error>()
    fetchAssertion.expectValue()
    fetchAssertion.subscribe(to: fetchPublisher(ChatInfo.Query(userId: contactA.id)))
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(fetchAssertion.receivedValues(), [expectedFetchResults])
    XCTAssertNil(fetchAssertion.receivedCompletion())
  }
}
