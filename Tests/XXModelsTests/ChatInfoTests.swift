import XCTest
@testable import XXModels

final class ChatInfoTests: XCTestCase {
  func testContactChat() {
    let contact = Contact(
      id: "contact-id".data(using: .utf8)!,
      connected: false
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

    let chatInfo = ChatInfo.contactChat(contactChatInfo)

    XCTAssertEqual(chatInfo.id, .contactChat(contactChatInfo.id))
    XCTAssertEqual(chatInfo.date, contactChatInfo.lastMessage.date)
  }

  func testGroupChat() {
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

    let chatInfo = ChatInfo.groupChat(groupChatInfo)

    XCTAssertEqual(chatInfo.id, .groupChat(groupChatInfo.id))
    XCTAssertEqual(chatInfo.date, groupChatInfo.lastMessage.date)
  }

  func testGroup() {
    let group = Group(
      id: "group-id".data(using: .utf8)!,
      name: "",
      leaderId: "leader-contact-id".data(using: .utf8)!,
      createdAt: Date()
    )

    let chatInfo = ChatInfo.group(group)

    XCTAssertEqual(chatInfo.id, .group(group.id))
    XCTAssertEqual(chatInfo.date, group.createdAt)
  }
}
