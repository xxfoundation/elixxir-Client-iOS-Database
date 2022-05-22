import Combine

public struct ContactChatInfo: Identifiable, Equatable, Codable {
  public typealias ID = Contact.ID

  public init(
    contact: Contact,
    lastMessage: Message,
    unreadCount: Int
  ) {
    self.contact = contact
    self.lastMessage = lastMessage
    self.unreadCount = unreadCount
  }

  public var id: ID { contact.id }
  public var contact: Contact
  public var lastMessage: Message
  public var unreadCount: Int
}

extension ContactChatInfo {
  public typealias Fetch = (Query) throws -> [ContactChatInfo]
  public typealias FetchPublisher = (Query) -> AnyPublisher<[ContactChatInfo], Error>

  public struct Query: Equatable {
    public init(userId: Contact.ID) {
      self.userId = userId
    }

    public var userId: Contact.ID
  }
}
