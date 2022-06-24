import CustomDump
import XCTest
import XXModels
@testable import XXDatabase

final class ContactChatInfoGRDBTests: XCTestCase {
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
    let contactE = try db.saveContact(.stub("E"))

    // Mock up conversation between contact A and B:

    try db.saveMessage(.stub(
      from: contactA,
      to: contactB,
      at: 1,
      isUnread: false
    ))

    try db.saveMessage(.stub(
      from: contactB,
      to: contactA,
      at: 2,
      isUnread: true
    ))

    let lastMessage_betweenAandB_at3 = try db.saveMessage(.stub(
      from: contactA,
      to: contactB,
      at: 3,
      isUnread: true
    ))

    // Mock up conversation between contact A and C:

    try db.saveMessage(.stub(
      from: contactA,
      to: contactC,
      at: 4,
      isUnread: true
    ))

    let lastMessage_betweenAandC_at5 = try db.saveMessage(.stub(
      from: contactC,
      to: contactA,
      at: 5,
      isUnread: false
    ))

    // Mock up conversation between contact B and C:

    try db.saveMessage(.stub(
      from: contactB,
      to: contactC,
      at: 6,
      isUnread: false
    ))

    let lastMessage_betweenBandC_at7 = try db.saveMessage(.stub(
      from: contactC,
      to: contactB,
      at: 7,
      isUnread: false
    ))

    // Mock up conversation between contact D and E:

    try db.saveMessage(.stub(
      from: contactD,
      to: contactE,
      at: 8,
      isUnread: false
    ))

    try db.saveMessage(.stub(
      from: contactE,
      to: contactD,
      at: 9,
      isUnread: false
    ))

    // Fetch contact chat infos for user A:

    XCTAssertNoDifference(
      try db.fetchContactChatInfos(ContactChatInfo.Query(userId: contactA.id)),
      [
        ContactChatInfo(
          contact: contactC,
          lastMessage: lastMessage_betweenAandC_at5,
          unreadCount: 1
        ),
        ContactChatInfo(
          contact: contactB,
          lastMessage: lastMessage_betweenAandB_at3,
          unreadCount: 2
        ),
      ]
    )

    // Fetch contact chat infos for user B:

    XCTAssertNoDifference(
      try db.fetchContactChatInfos(ContactChatInfo.Query(userId: contactB.id)),
      [
        ContactChatInfo(
          contact: contactC,
          lastMessage: lastMessage_betweenBandC_at7,
          unreadCount: 0
        ),
        ContactChatInfo(
          contact: contactA,
          lastMessage: lastMessage_betweenAandB_at3,
          unreadCount: 2
        ),
      ]
    )

    // Fetch contact chat infos for user C:

    XCTAssertNoDifference(
      try db.fetchContactChatInfos(ContactChatInfo.Query(userId: contactC.id)),
      [
        ContactChatInfo(
          contact: contactB,
          lastMessage: lastMessage_betweenBandC_at7,
          unreadCount: 0
        ),
        ContactChatInfo(
          contact: contactA,
          lastMessage: lastMessage_betweenAandC_at5,
          unreadCount: 1
        ),
      ]
    )
  }

  func testFetchingByContactAuthStatus() throws {
    // Mock up contacts:

    let contactA = try db.saveContact(.stub("A"))
    let contactB = try db.saveContact(.stub("B", authStatus: .friend))
    let contactC = try db.saveContact(.stub("C", authStatus: .hidden))
    let contactD = try db.saveContact(.stub("D", authStatus: .stranger))

    // Mock up conversation between contact A and B:

    try db.saveMessage(.stub(
      from: contactA,
      to: contactB,
      at: 1,
      isUnread: false
    ))

    try db.saveMessage(.stub(
      from: contactB,
      to: contactA,
      at: 2,
      isUnread: true
    ))

    let lastMessage_betweenAandB_at3 = try db.saveMessage(.stub(
      from: contactA,
      to: contactB,
      at: 3,
      isUnread: true
    ))

    // Mock up conversation between contact A and C:

    try db.saveMessage(.stub(
      from: contactA,
      to: contactC,
      at: 4,
      isUnread: false
    ))

    let lastMessage_betweenAandC_at5 = try db.saveMessage(.stub(
      from: contactC,
      to: contactA,
      at: 5,
      isUnread: true
    ))

    // Mock up conversation between contact A and D:

    try db.saveMessage(.stub(
      from: contactA,
      to: contactD,
      at: 6,
      isUnread: false
    ))

    let lastMessage_betweenAandD_at7 = try db.saveMessage(.stub(
      from: contactD,
      to: contactA,
      at: 7,
      isUnread: false
    ))

    // Fetch contact chat infos for contact A, filtered by other contact auth status:

    XCTAssertNoDifference(
      try db.fetchContactChatInfos(ContactChatInfo.Query(
        userId: contactA.id,
        authStatus: [.friend, .stranger]
      )),
      [
        ContactChatInfo(
          contact: contactD,
          lastMessage: lastMessage_betweenAandD_at7,
          unreadCount: 0
        ),
        ContactChatInfo(
          contact: contactB,
          lastMessage: lastMessage_betweenAandB_at3,
          unreadCount: 2
        ),
      ]
    )

    // Fetch contact chat infos for contact A, regardless other contact auth status:

    XCTAssertNoDifference(
      try db.fetchContactChatInfos(ContactChatInfo.Query(
        userId: contactA.id,
        authStatus: nil
      )),
      [
        ContactChatInfo(
          contact: contactD,
          lastMessage: lastMessage_betweenAandD_at7,
          unreadCount: 0
        ),
        ContactChatInfo(
          contact: contactC,
          lastMessage: lastMessage_betweenAandC_at5,
          unreadCount: 1
        ),
        ContactChatInfo(
          contact: contactB,
          lastMessage: lastMessage_betweenAandB_at3,
          unreadCount: 2
        ),
      ]
    )
  }
}
