import CustomDump
import XCTest
import XXModels
@testable import XXDatabase

final class ChatInfoTests: XCTestCase {
  var db: Database!

  override func setUp() async throws {
    db = try Database.inMemory()
  }

  override func tearDown() async throws {
    db = nil
  }

  func testFetching() throws {
    let fetch: ChatInfo.Fetch = db.fetch(_:)
    let fetchPublisher: ChatInfo.FetchPublisher = db.fetchPublisher(_:)

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

    _ = try db.insert(GroupMember(groupId: groupA.id, contactId: contactA.id))
    _ = try db.insert(GroupMember(groupId: groupA.id, contactId: contactB.id))
    _ = try db.insert(GroupMember(groupId: groupA.id, contactId: contactC.id))

    let groupB = try db.insert(Group.stub(
      "B",
      leaderId: contactB.id,
      createdAt: .stub(2)
    ))

    _ = try db.insert(GroupMember(groupId: groupB.id, contactId: contactB.id))
    _ = try db.insert(GroupMember(groupId: groupB.id, contactId: contactC.id))
    _ = try db.insert(GroupMember(groupId: groupB.id, contactId: contactD.id))

    _ = try db.insert(Group.stub(
      "C",
      leaderId: contactC.id,
      createdAt: .stub(3)
    ))

    // Mock up messages in group A:

    _ = try db.insert(Message.stub(
      from: contactA,
      to: groupA,
      at: 1,
      isUnread: true
    ))

    _ = try db.insert(Message.stub(
      from: contactB,
      to: groupA,
      at: 2,
      isUnread: false
    ))

    _ = try db.insert(Message.stub(
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

    _ = try db.insert(Message.stub(
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

    _ = try db.insert(Message.stub(
      from: contactD,
      to: groupB,
      at: 5,
      isUnread: false
    ))

    _ = try db.insert(Message.stub(
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

    _ = try db.insert(Message.stub(
      from: contactB,
      to: contactC,
      at: 8,
      isUnread: false
    ))

    let _ = try db.insert(Message.stub(
      from: contactC,
      to: contactB,
      at: 9,
      isUnread: false
    ))

    // Mock up messages between contact A and C:

    _ = try db.insert(Message.stub(
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
      .contact(ContactChatInfo(
        contact: contactC,
        lastMessage: lastMessage_betweenAandC_at11,
        unreadCount: 2
      )),
      .group(GroupChatInfo(
        group: groupB,
        lastMessage: lastMessage_inGroupB_at7,
        unreadCount: 0
      )),
      .contact(ContactChatInfo(
        contact: contactB,
        lastMessage: lastMessage_betweenAandB_at6,
        unreadCount: 1
      )),
      .group(GroupChatInfo(
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
