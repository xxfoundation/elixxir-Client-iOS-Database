/// Represents chat with a contact
public struct ContactChatInfo: Identifiable, Equatable, Hashable, Codable {
  /// Unique identifier of contact chat
  public typealias ID = Contact.ID

  /// Instantiate contact chat representation
  ///
  /// - Parameters:
  ///   - contact: Contact
  ///   - lastMessage: Last message sent to or received from the contact
  ///   - unreadCount: Number of unread messages in the chat
  public init(
    contact: Contact,
    lastMessage: Message,
    unreadCount: Int
  ) {
    self.contact = contact
    self.lastMessage = lastMessage
    self.unreadCount = unreadCount
  }

  /// Unique identifier of contact chat
  ///
  /// Matches contact's ID
  public var id: ID { contact.id }

  /// Contact
  public var contact: Contact

  /// Last message sent to or received from the contact
  public var lastMessage: Message

  /// Number of unread messages in the chat
  public var unreadCount: Int
}

extension ContactChatInfo {
  /// Fetch contact chat infos operation
  public typealias Fetch = XXModels.Fetch<ContactChatInfo, Query>

  /// Fetch contact chat infos operation publisher
  public typealias FetchPublisher = XXModels.FetchPublisher<ContactChatInfo, Query>

  /// Query used for fetching chat infos
  public struct Query: Equatable {
    /// Instantiate query
    ///
    /// - Parameters:
    ///   - userId: Current user's contact ID.
    ///   - authStatus: Filter by other contact auth status.
    ///     If set, only chats with contacts that have any of the provided
    ///     auth statuses will be included.
    ///     If `nil` (default), the filter is not used.
    public init(
      userId: Contact.ID,
      authStatus: Set<Contact.AuthStatus>? = nil
    ) {
      self.userId = userId
      self.authStatus = authStatus
    }

    /// Current user's contact ID
    public var userId: Contact.ID

    /// Filter by other contact auth status
    ///
    /// If set, only chats with contacts that have any of the provided
    /// auth statuses will be included.
    /// If `nil`, the filter is not used.
    public var authStatus: Set<Contact.AuthStatus>?
  }
}
