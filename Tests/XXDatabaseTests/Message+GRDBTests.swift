import CustomDump
import XCTest
import XXModels
@testable import XXDatabase

final class MessageGRDBTests: XCTestCase {
  var db: Database!

  override func setUp() async throws {
    db = try Database.inMemory()
  }

  override func tearDown() async throws {
    db = nil
  }

  func testFetchingDirectMessages() throws {
    let fetch: Message.Fetch = db.fetch(Message.request(_:))
    let save: Message.Save = db.save()

    let contactA = Contact.stub("A")
    let contactB = Contact.stub("B")
    let contactC = Contact.stub("C")

    try db.insert(contactA)
    try db.insert(contactB)
    try db.insert(contactC)

    // Save conversation between contacts A and B:

    let message1 = try save(.stub(
      from: contactA,
      to: contactB,
      at: 1
    ))

    let message2 = try save(.stub(
      from: contactB,
      to: contactA,
      at: 2
    ))

    let message3 = try save(.stub(
      from: contactA,
      to: contactB,
      at: 3
    ))

    // Save other messages:

    _ = try save(.stub(
      from: contactA,
      to: contactC,
      at: 1
    ))

    _ = try save(.stub(
      from: contactC,
      to: contactA,
      at: 1
    ))

    _ = try save(.stub(
      from: contactB,
      to: contactC,
      at: 1
    ))

    _ = try save(.stub(
      from: contactC,
      to: contactB,
      at: 1
    ))

    // Fetch conversation between contacts A and B:

    XCTAssertNoDifference(
      try fetch(Message.Query(chat: .direct(contactA.id, contactB.id), sortBy: .date())),
      [
        message1,
        message2,
        message3,
      ]
    )
  }

  func testFetchingGroupMessages() throws {
    let fetch: Message.Fetch = db.fetch(Message.request(_:))
    let save: Message.Save = db.save()

    let contactA = Contact.stub("A")
    let contactB = Contact.stub("B")
    let contactC = Contact.stub("C")

    try db.insert(contactA)
    try db.insert(contactB)
    try db.insert(contactC)

    let groupA = Group.stub("A", leaderId: contactA.id, createdAt: .stub(1))
    let groupB = Group.stub("B", leaderId: contactB.id, createdAt: .stub(2))

    try db.save(groupA)
    try db.save(groupB)

    // Save group A messages:

    let message1 = try save(.stub(
      from: contactA,
      to: groupA,
      at: 1
    ))

    let message2 = try save(.stub(
      from: contactB,
      to: groupA,
      at: 2
    ))

    let message3 = try save(.stub(
      from: contactC,
      to: groupA,
      at: 3
    ))

    // Save other messages:

    _ = try save(.stub(
      from: contactA,
      to: contactC,
      at: 1
    ))

    _ = try save(.stub(
      from: contactC,
      to: contactA,
      at: 1
    ))

    _ = try save(.stub(
      from: contactB,
      to: contactC,
      at: 1
    ))

    _ = try save(.stub(
      from: contactC,
      to: contactB,
      at: 1
    ))

    _ = try save(.stub(
      from: contactA,
      to: groupB,
      at: 1
    ))

    _ = try save(.stub(
      from: contactB,
      to: groupB,
      at: 1
    ))

    _ = try save(.stub(
      from: contactC,
      to: groupB,
      at: 1
    ))

    // Fetch messages in group A:

    XCTAssertNoDifference(
      try fetch(Message.Query(chat: .group(groupA.id), sortBy: .date(desc: true))),
      [
        message3,
        message2,
        message1,
      ]
    )
  }

  func testFetchingById() throws {
    let fetch: Message.Fetch = db.fetch(Message.request(_:))
    let save: Message.Save = db.save()

    // Mock up contacts

    let contactA = Contact.stub("A")
    let contactB = Contact.stub("B")
    let contactC = Contact.stub("C")

    try db.insert(contactA)
    try db.insert(contactB)
    try db.insert(contactC)

    // Mock up messages:

    let message1 = try save(.stub(
      from: contactA,
      to: contactB,
      at: 1
    ))

    let message2 = try save(.stub(
      from: contactB,
      to: contactA,
      at: 2
    ))

    let message3 = try save(.stub(
      from: contactA,
      to: contactC,
      at: 3
    ))

    // Fetch messages by id:

    XCTAssertNoDifference(
      try fetch(.init(id: message1.id, sortBy: .date())),
      [message1]
    )

    XCTAssertNoDifference(
      try fetch(.init(id: message2.id, sortBy: .date())),
      [message2]
    )

    XCTAssertNoDifference(
      try fetch(.init(id: message3.id, sortBy: .date())),
      [message3]
    )
  }

  func testFetchingByNetworkId() throws {
    let fetch: Message.Fetch = db.fetch(Message.request(_:))
    let save: Message.Save = db.save()

    // Mock up contacts

    let contactA = Contact.stub("A")
    let contactB = Contact.stub("B")
    let contactC = Contact.stub("C")

    try db.insert(contactA)
    try db.insert(contactB)
    try db.insert(contactC)

    // Mock up messages:

    let message1 = try save(.stub(
      from: contactA,
      to: contactB,
      at: 1,
      networkId: "1".data(using: .utf8)!
    ))

    let message2 = try save(.stub(
      from: contactB,
      to: contactA,
      at: 2,
      networkId: "2".data(using: .utf8)!
    ))

    let message3 = try save(.stub(
      from: contactA,
      to: contactC,
      at: 3,
      networkId: nil
    ))

    // Fetch messages by network id:

    XCTAssertNoDifference(
      try fetch(.init(networkId: "1".data(using: .utf8)!, sortBy: .date())),
      [message1]
    )

    XCTAssertNoDifference(
      try fetch(.init(networkId: "2".data(using: .utf8)!, sortBy: .date())),
      [message2]
    )

    XCTAssertNoDifference(
      try fetch(.init(networkId: .some(nil), sortBy: .date())),
      [message3]
    )

    XCTAssertNoDifference(
      try fetch(.init(networkId: .none, sortBy: .date())),
      [message1, message2, message3]
    )
  }
}
