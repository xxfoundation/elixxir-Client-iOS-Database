import Foundation

/// Represents message
public struct Message: Identifiable, Equatable, Hashable, Codable {
  /// Unique identifier of a message
  public typealias ID = Int64?

  /// Represents status of the message
  public enum Status: String, Equatable, Hashable, Codable {
    /// Outgoing message is sending
    case sending

    /// Outgoing message sending timed out
    case sendingTimedOut

    /// Outgoing message sending failed
    case sendingFailed

    /// Outgoing message successfully sent
    case sent

    /// Incoming message receiving in progress
    case receiving

    /// Incoming message receiving failed
    case receivingFailed

    /// Incoming message successfully received
    case received
  }

  /// Instantiate message representation
  /// - Parameters:
  ///   - id: Unique identifier of the message
  ///   - networkId: Network identifier of the message (defaults to `nil`)
  ///   - senderId: Sender's contact ID
  ///   - recipientId: Recipient's contact ID
  ///   - groupId: Message group ID
  ///   - date: Message date
  ///   - status: Message status
  ///   - isUnread: Unread status
  ///   - text: Text
  ///   - replyMessageId: Network id of the message this message replies to (defaults to `nil`)
  ///   - roundURL: Network round URL (defaults to `nil`)
  ///   - fileTransferId: File transfer id (defaults to `nil`)
  public init(
    id: ID = nil,
    networkId: Data? = nil,
    senderId: Contact.ID,
    recipientId: Contact.ID?,
    groupId: Group.ID?,
    date: Date,
    status: Status,
    isUnread: Bool,
    text: String,
    replyMessageId: Data? = nil,
    roundURL: String? = nil,
    fileTransferId: FileTransfer.ID? = nil
  ) {
    self.id = id
    self.networkId = networkId
    self.senderId = senderId
    self.recipientId = recipientId
    self.groupId = groupId
    self.date = date
    self.status = status
    self.isUnread = isUnread
    self.text = text
    self.replyMessageId = replyMessageId
    self.roundURL = roundURL
    self.fileTransferId = fileTransferId
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

  /// Message status
  public var status: Status

  /// Unread status
  public var isUnread: Bool

  /// Text
  public var text: String

  /// Network id of the message this message replies to
  public var replyMessageId: Data?

  /// Network round URL
  public var roundURL: String?

  /// File transfer id
  public var fileTransferId: FileTransfer.ID?
}

extension Message {
  /// Fetch messages operation
  public typealias Fetch = XXModels.Fetch<Message, Query>

  /// Fetch messages operation publisher
  public typealias FetchPublisher = XXModels.FetchPublisher<Message, Query>

  /// Save message operation
  public typealias Save = XXModels.Save<Message>

  /// Bulk update operation
  public typealias BulkUpdate = XXModels.BulkUpdate<Query, Assignments>

  /// Delete message operation
  public typealias Delete = XXModels.Delete<Message>

  /// Delete messages operation
  public typealias DeleteMany = XXModels.DeleteMany<Message, Query>

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
    ///   - id: Filter by message id (defaults to `nil`).
    ///   - networkId: Filter by network id (defaults to `nil`).
    ///   - chat: Chat filter.
    ///     If `.direct(idA, idB)`, get direct messages between contacts with provided ids.
    ///     If `.group(groupId)`, get messages within group with provided id.
    ///     If `.none` (default), disable the filter.
    ///   - status: Filter messages by status.
    ///     If set, only messages with any of the provided statuses will be included.
    ///     If `nil` (default), the filter is not used.
    ///   - isUnread: Filter by unread status.
    ///     If `true`, get only unread messages.
    ///     If `false`, get only read messages.
    ///     If `nil` (default), disable the filter.
    ///   - fileTransferId: Filter by file transfer id.
    ///     If `.some(.some(fileTransferId))`, get messages with provided `fileTransferId`.
    ///     If `.some(.none)`, get messages without `fileTransferId`.
    ///     If `.none` (default), disable the filter.
    ///   - sortBy: Sort order (defaults to `.date()`).
    public init(
      id: Set<Message.ID>? = nil,
      networkId: Data?? = nil,
      chat: Chat? = nil,
      status: Set<Status>? = nil,
      isUnread: Bool? = nil,
      fileTransferId: FileTransfer.ID?? = nil,
      sortBy: SortOrder = .date()
    ) {
      self.id = id
      self.networkId = networkId
      self.chat = chat
      self.status = status
      self.isUnread = isUnread
      self.fileTransferId = fileTransferId
      self.sortBy = sortBy
    }

    /// Filter by message id
    public var id: Set<Message.ID>?

    /// Filter by network id
    ///
    /// If `.some(.some(networkId))`, get messages with provided `networkId`.
    /// If `.some(.none)`, get messages without `networkId`.
    /// If `.none`, disable the filter.
    public var networkId: Data??

    /// Chat filter
    /// 
    /// If `.direct(idA, idB)`, get direct messages between contacts with provided ids.
    /// If `.group(groupId)`, get messages within group with provided id.
    /// If `.none`, disable the filter.
    public var chat: Chat?

    /// Filter messages by status
    ///
    /// If set, only messages with any of the provided statuses will be included.
    /// If `nil`, the filter is not used.
    public var status: Set<Status>?

    /// Filter by unread status
    ///
    /// If `true`, get only unread messages.
    /// If `false`, get only read messages.
    /// If `nil`, disable the filter.
    public var isUnread: Bool?

    /// Filter by file transfer id
    ///
    /// If `.some(.some(fileTransferId))`, get messages with provided `fileTransferId`.
    /// If `.some(.none)`, get messages without `fileTransferId`.
    /// If `.none`, disable the filter.
    public var fileTransferId: FileTransfer.ID??

    /// Messages sort order
    public var sortBy: SortOrder
  }

  /// Bulk update definition
  public struct Assignments: Equatable {
    /// Instantiate definition
    ///
    /// - Parameters:
    ///   - status: Set message status.
    ///     If provided, change status to the given value.
    ///     If `nil` (default), do not change status.
    ///   - isUnread: Set `isUnread` flag.
    ///     If provided, change `isUnread` flag to given value.
    ///     If `nil` (default), do not change `isUnread` flag.
    public init(
      status: Status? = nil,
      isUnread: Bool? = nil
    ) {
      self.status = status
      self.isUnread = isUnread
    }

    /// Set message status
    ///
    /// If provided, change status to the given value.
    /// If `nil`, do not change status.
    public var status: Status?

    /// Set `isUnread` flag
    ///
    /// If provided, change `isUnread` flag to given value.
    /// If `nil`, do not change `isUnread` flag.
    public var isUnread: Bool?
  }
}
