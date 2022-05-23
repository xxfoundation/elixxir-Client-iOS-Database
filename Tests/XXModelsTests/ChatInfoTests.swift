import XCTest
@testable import XXModels

final class ChatInfoTests: XCTestCase {
  func testContactChat() {
    let contact = Contact(
      id: "contact-id".data(using: .utf8)!
    )

    let lastMessage = Message(
      id: 111,
      networkId: nil,
      senderId: Data(),
      recipientId: nil,
      groupId: nil,
      date: Date(),
      isUnread: false,
      text: ""
    )

    let contactChatInfo = ContactChatInfo(
      contact: contact,
      lastMessage: lastMessage,
      unreadCount: 222
    )

    let chatInfo = ChatInfo.contact(contactChatInfo)

    XCTAssertEqual(chatInfo.id, .contact(contactChatInfo.id))
    XCTAssertEqual(chatInfo.lastMessage, contactChatInfo.lastMessage)
    XCTAssertEqual(chatInfo.unreadCount, contactChatInfo.unreadCount)
  }

  func testGroupChatInfo() {
    let group = Group(
      id: "group-id".data(using: .utf8)!,
      name: "",
      leaderId: "leader-contact-id".data(using: .utf8)!,
      createdAt: Date()
    )

    let lastMessage = Message(
      id: 111,
      networkId: nil,
      senderId: Data(),
      recipientId: nil,
      groupId: nil,
      date: Date(),
      isUnread: false,
      text: ""
    )

    let groupChatInfo = GroupChatInfo(
      group: group,
      lastMessage: lastMessage,
      unreadCount: 222
    )

    let chatInfo = ChatInfo.group(groupChatInfo)

    XCTAssertEqual(chatInfo.id, .group(groupChatInfo.id))
    XCTAssertEqual(chatInfo.lastMessage, groupChatInfo.lastMessage)
    XCTAssertEqual(chatInfo.unreadCount, groupChatInfo.unreadCount)
  }
}
