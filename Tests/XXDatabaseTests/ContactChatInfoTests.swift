import CustomDump
import XCTest
import XXModels
@testable import XXDatabase

final class ContactChatInfoTests: XCTestCase {
  var db: Database!

  override func setUp() async throws {
    db = try Database.inMemory()
  }

  override func tearDown() async throws {
    db = nil
  }

  func testFetching() throws {
    let fetch: ContactChatInfo.Fetch = db.fetch(ContactChatInfo.request(_:))

    // Mock up contacts:

    let contactA = try db.insert(Contact.stub("A"))
    let contactB = try db.insert(Contact.stub("B"))
    let contactC = try db.insert(Contact.stub("C"))
    let contactD = try db.insert(Contact.stub("D"))
    let contactE = try db.insert(Contact.stub("E"))

    // Mock up conversation between contact A and B:

    _ = try db.insert(Message.stub(
      from: contactA,
      to: contactB,
      at: 1
    ))

    _ = try db.insert(Message.stub(
      from: contactB,
      to: contactA,
      at: 2
    ))

    let lastMessage_betweenAandB_at3 = try db.insert(Message.stub(
      from: contactA,
      to: contactB,
      at: 3
    ))

    // Mock up conversation between contact A and C:

    _ = try db.insert(Message.stub(
      from: contactA,
      to: contactC,
      at: 4
    ))

    let lastMessage_betweenAandC_at5 = try db.insert(Message.stub(
      from: contactC,
      to: contactA,
      at: 5
    ))

    // Mock up conversation between contact B and C:

    _ = try db.insert(Message.stub(
      from: contactB,
      to: contactC,
      at: 6
    ))

    let lastMessage_betweenBandC_at7 = try db.insert(Message.stub(
      from: contactC,
      to: contactB,
      at: 7
    ))

    // Mock up conversation between contact D and E:

    _ = try db.insert(Message.stub(
      from: contactD,
      to: contactE,
      at: 8
    ))

    _ = try db.insert(Message.stub(
      from: contactE,
      to: contactD,
      at: 9
    ))

    // Fetch contact chat infos for user A:

    XCTAssertNoDifference(try fetch(ContactChatInfo.Query(userId: contactA.id)), [
      ContactChatInfo(contact: contactC, lastMessage: lastMessage_betweenAandC_at5),
      ContactChatInfo(contact: contactB, lastMessage: lastMessage_betweenAandB_at3),
    ])

    // Fetch contact chat infos for user B:

    XCTAssertNoDifference(try fetch(ContactChatInfo.Query(userId: contactB.id)), [
      ContactChatInfo(contact: contactC, lastMessage: lastMessage_betweenBandC_at7),
      ContactChatInfo(contact: contactA, lastMessage: lastMessage_betweenAandB_at3),
    ])

    // Fetch contact chat infos for user C:

    XCTAssertNoDifference(try fetch(ContactChatInfo.Query(userId: contactC.id)), [
      ContactChatInfo(contact: contactB, lastMessage: lastMessage_betweenBandC_at7),
      ContactChatInfo(contact: contactA, lastMessage: lastMessage_betweenAandC_at5),
    ])
  }
}
