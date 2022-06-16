import XCTest
@testable import XXModels

final class ContactChatInfoTests: XCTestCase {
  func testId() {
    let contact = Contact(
      id: "contact-id".data(using: .utf8)!
    )

    let message = Message(
      senderId: "sender-id".data(using: .utf8)!,
      recipientId: nil,
      groupId: nil,
      date: Date(timeIntervalSince1970: 1234),
      status: .received,
      isUnread: true,
      text: "text"
    )

    let chatInfo = ContactChatInfo(
      contact: contact,
      lastMessage: message,
      unreadCount: 1234
    )

    XCTAssertEqual(chatInfo.id, contact.id)
  }
}
