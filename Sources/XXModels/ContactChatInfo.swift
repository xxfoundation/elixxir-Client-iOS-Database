import Combine

public struct ContactChatInfo: Identifiable, Equatable, Codable {
  public typealias ID = Contact.ID

  public init(
    contact: Contact,
    lastMessage: Message
  ) {
    self.contact = contact
    self.lastMessage = lastMessage
  }

  public var id: ID { contact.id }
  public var contact: Contact
  public var lastMessage: Message
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
