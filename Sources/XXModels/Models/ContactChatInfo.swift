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
  public typealias Fetch = XXModels.Fetch<ContactChatInfo, Query>
  public typealias FetchPublisher = XXModels.FetchPublisher<ContactChatInfo, Query>

  public struct Query: Equatable {
    public init(userId: Contact.ID) {
      self.userId = userId
    }

    public var userId: Contact.ID
  }
}
