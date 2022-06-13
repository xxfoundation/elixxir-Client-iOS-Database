import Combine
import Foundation

/// Represents message
public struct Message: Identifiable, Equatable, Codable {
  /// Unique identifier of a message
  public typealias ID = Int64?

  /// Instantiate message representation
  /// - Parameters:
  ///   - id: Unique identifier of the message
  ///   - networkId: Unique xx network identifier of the message
  ///   - senderId: Sender's contact ID
  ///   - recipientId: Recipient's contact ID
  ///   - groupId: Message group ID
  ///   - date: Message date
  ///   - isUnread: Unread status
  ///   - text: Text
  ///   - replayMessageId: Network id of the message this message replays to
  public init(
    id: ID = nil,
    networkId: Data? = nil,
    senderId: Contact.ID,
    recipientId: Contact.ID?,
    groupId: Group.ID?,
    date: Date,
    isUnread: Bool,
    text: String,
    replayMessageId: Data? = nil
  ) {
    self.id = id
    self.networkId = networkId
    self.senderId = senderId
    self.recipientId = recipientId
    self.groupId = groupId
    self.date = date
    self.isUnread = isUnread
    self.text = text
    self.replayMessageId = replayMessageId
  }

  /// Unique identifier of the message
  ///
  /// It's `nil` for messages that are not yet persisted.
  public var id: ID

  /// Unique xx network identifier of the message
  public var networkId: Data?

  /// Sender's contact ID
  public var senderId: Contact.ID

  /// Recipient's contact ID
  ///
  /// It can be `nil` for messages sent to a group.
  public var recipientId: Contact.ID?

  /// Message group ID
  ///
  /// It can be `nil` for direct messages.
  public var groupId: Group.ID?

  /// Message date
  public var date: Date

  /// Unread status
  public var isUnread: Bool

  /// Text
  public var text: String

  /// Network id of the message this message replays to
  public var replayMessageId: Data?
}

extension Message {
  /// Fetch messages operation
  public typealias Fetch = XXModels.Fetch<Message, Query>

  /// Fetch messages operation publisher
  public typealias FetchPublisher = XXModels.FetchPublisher<Message, Query>

  /// Save message operation
  public typealias Save = XXModels.Save<Message>

  /// Delete message operation
  public typealias Delete = XXModels.Delete<Message>

  /// Query used for fetching messages
  public struct Query: Equatable {
    /// Chat filter
    public enum Chat: Equatable {
      /// Include direct messages sent between provided contacts
      ///
      /// - Parameters:
      ///   - idA: First contact ID
      ///   - idB: Second contact ID
      case direct(_ idA: Contact.ID, _ idB: Contact.ID)

      /// Include group messages
      ///
      /// - Parameters:
      ///   - groupId: Group ID
      case group(_ groupId: Group.ID)
    }

    /// Messages sort order
    public enum SortOrder: Equatable {
      /// Sort by date
      ///
      /// - Parameters:
      ///   - desc: Sort in descending order (defaults to `false`)
      case date(desc: Bool = false)
    }

    /// Instantiate messages query
    ///
    /// - Parameters:
    ///   - chat: Chat filter (defaults to `nil`)
    ///   - sortBy: Sort order
    public init(
      chat: Chat? = nil,
      sortBy: SortOrder
    ) {
      self.chat = chat
      self.sortBy = sortBy
    }

    /// Messages chat filter
    public var chat: Chat?

    /// Messages sort order
    public var sortBy: SortOrder
  }
}
