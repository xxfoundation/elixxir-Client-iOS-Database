import CustomDump
import XCTest
import XXModels
@testable import XXDatabase

final class MessageTests: XCTestCase {
  var db: Database!

  override func setUp() async throws {
    db = try Database.inMemory()
  }

  override func tearDown() async throws {
    db = nil
  }

  func testFetchingDirectMessages() throws {
    let fetch: Message.Fetch = db.fetch(Message.request(_:_:))
    let save: Message.Save = db.save(_:)

    let contactA = Contact.stub(1)
    let contactB = Contact.stub(2)
    let contactC = Contact.stub(3)

    _ = try db.insert(contactA)
    _ = try db.insert(contactB)
    _ = try db.insert(contactC)

    // Save conversation between contacts A and B:

    let message1 = try save(.stub(
      senderId: contactA.id,
      recipientId: contactB.id,
      date: .stub(1),
      text: "Hello B"
    ))

    let message2 = try save(.stub(
      senderId: contactB.id,
      recipientId: contactA.id,
      date: .stub(2),
      text: "Hi A, how are you?"
    ))

    let message3 = try save(.stub(
      senderId: contactA.id,
      recipientId: contactB.id,
      date: .stub(3),
      text: "I'm fine, thank you!"
    ))

    // Save other messages:

    _ = try save(.stub(
      senderId: contactA.id,
      recipientId: contactC.id,
      date: .stub(1),
      text: ""
    ))

    _ = try save(.stub(
      senderId: contactC.id,
      recipientId: contactA.id,
      date: .stub(1),
      text: ""
    ))

    _ = try save(.stub(
      senderId: contactB.id,
      recipientId: contactC.id,
      date: .stub(1),
      text: ""
    ))

    _ = try save(.stub(
      senderId: contactC.id,
      recipientId: contactB.id,
      date: .stub(1),
      text: ""
    ))

    // Fetch conversation between contacts A and B:

    XCTAssertNoDifference(
      try fetch(.directChat(contactIds: contactA.id, contactB.id), .date()),
      [
        message1,
        message2,
        message3,
      ]
    )
  }

  func testFetchingGroupMessages() throws {
    let fetch: Message.Fetch = db.fetch(Message.request(_:_:))
    let save: Message.Save = db.save(_:)

    let contactA = Contact.stub(1)
    let contactB = Contact.stub(2)
    let contactC = Contact.stub(3)

    _ = try db.insert(contactA)
    _ = try db.insert(contactB)
    _ = try db.insert(contactC)

    let groupA = Group.stub(1, leaderId: contactA.id)
    let groupB = Group.stub(2, leaderId: contactB.id)

    _ = try db.save(groupA)
    _ = try db.save(groupB)

    // Save group A messages:

    let message1 = try save(.stub(
      senderId: contactA.id,
      recipientId: groupA.id,
      date: .stub(1),
      text: "Hello everyone. Welcome in my group!"
    ))

    let message2 = try save(.stub(
      senderId: contactB.id,
      recipientId: groupA.id,
      date: .stub(2),
      text: "Hello A!"
    ))

    let message3 = try save(.stub(
      senderId: contactC.id,
      recipientId: groupA.id,
      date: .stub(3),
      text: "Greetings from C!"
    ))

    // Save other messages:

    _ = try save(.stub(
      senderId: contactA.id,
      recipientId: contactC.id,
      date: .stub(1),
      text: ""
    ))

    _ = try save(.stub(
      senderId: contactC.id,
      recipientId: contactA.id,
      date: .stub(1),
      text: ""
    ))

    _ = try save(.stub(
      senderId: contactB.id,
      recipientId: contactC.id,
      date: .stub(1),
      text: ""
    ))

    _ = try save(.stub(
      senderId: contactC.id,
      recipientId: contactB.id,
      date: .stub(1),
      text: ""
    ))

    _ = try save(.stub(
      senderId: contactA.id,
      recipientId: groupB.id,
      date: .stub(1),
      text: ""
    ))

    _ = try save(.stub(
      senderId: contactB.id,
      recipientId: groupB.id,
      date: .stub(1),
      text: ""
    ))

    _ = try save(.stub(
      senderId: contactC.id,
      recipientId: groupB.id,
      date: .stub(1),
      text: ""
    ))

    // Fetch messages in group A:

    XCTAssertNoDifference(
      try fetch(.groupChat(groupId: groupA.id), .date(desc: true)),
      [
        message3,
        message2,
        message1,
      ]
    )
  }
}
