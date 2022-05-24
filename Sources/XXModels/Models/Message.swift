import Combine
import Foundation

public struct Message: Identifiable, Equatable, Codable {
  public typealias ID = Int64?

  public init(
    id: ID = nil,
    networkId: Data? = nil,
    senderId: Contact.ID,
    recipientId: Contact.ID?,
    groupId: Group.ID?,
    date: Date,
    isUnread: Bool,
    text: String
  ) {
    self.id = id
    self.networkId = networkId
    self.senderId = senderId
    self.recipientId = recipientId
    self.groupId = groupId
    self.date = date
    self.isUnread = isUnread
    self.text = text
  }

  public var id: ID
  public var networkId: Data?
  public var senderId: Contact.ID
  public var recipientId: Contact.ID?
  public var groupId: Group.ID?
  public var date: Date
  public var isUnread: Bool
  public var text: String
}

extension Message {
  public typealias Fetch = XXModels.Fetch<Message, Query>
  public typealias FetchPublisher = XXModels.FetchPublisher<Message, Query>
  public typealias Save = XXModels.Save<Message>
  public typealias Delete = XXModels.Delete<Message>

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
