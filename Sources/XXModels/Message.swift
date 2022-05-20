import Combine
import Foundation

public struct Message: Identifiable, Equatable, Codable {
  public typealias ID = Int64?

  public init(
    id: ID = nil,
    networkId: Data? = nil,
    senderId: Data,
    recipientId: Data,
    date: Date,
    isUnread: Bool,
    text: String
  ) {
    self.id = id
    self.networkId = networkId
    self.senderId = senderId
    self.recipientId = recipientId
    self.date = date
    self.isUnread = isUnread
    self.text = text
  }

  public var id: ID
  public var networkId: Data?
  public var senderId: Contact.ID
  public var recipientId: Data // TODO: handle contact and group recipients separately
  public var date: Date
  public var isUnread: Bool
  public var text: String
}

extension Message {
  public typealias Fetch = (Query) throws -> [Message]
  public typealias FetchPublisher = (Query) -> AnyPublisher<[Message], Error>
  public typealias Save = (Message) throws -> Message
  public typealias Delete = (Message) throws -> Bool

  public struct Query: Equatable {
    public enum Chat: Equatable {
      case direct(Contact.ID, Contact.ID)
      case group(Group.ID)
    }

    public enum SortOrder: Equatable {
      case date(desc: Bool = false)
    }

    public init(
      chat: Chat,
      sortBy: SortOrder
    ) {
      self.chat = chat
      self.sortBy = sortBy
    }

    public var chat: Chat
    public var sortBy: SortOrder
  }
}
