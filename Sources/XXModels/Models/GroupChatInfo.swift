/// Represents chat within a group
public struct GroupChatInfo: Identifiable, Equatable, Hashable, Codable {
  /// Unique identifier of group chat
  public typealias ID = Group.ID

  /// Instantiate group chat representation
  /// 
  /// - Parameters:
  ///   - group: Group
  ///   - lastMessage: Last message exchanged in the group
  ///   - unreadCount: Number of unread messages in the chat
  public init(
    group: Group,
    lastMessage: Message,
    unreadCount: Int
  ) {
    self.group = group
    self.lastMessage = lastMessage
    self.unreadCount = unreadCount
  }

  /// Unique identifier of group chat
  ///
  /// Matches group's ID
  public var id: ID { group.id }

  /// Group
  public var group: Group

  /// Last message exchanged within the group
  public var lastMessage: Message

  /// Number of unread messages in the chat
  public var unreadCount: Int
}

extension GroupChatInfo {
  /// Fetch group chat infos operation
  public typealias Fetch = XXModels.Fetch<GroupChatInfo, Query>

  /// Fetch group chat infos operation publisher
  public typealias FetchPublisher = XXModels.FetchPublisher<GroupChatInfo, Query>

  /// Query used for fetching group chat infos
  public struct Query: Equatable {
    /// Instantiate query
    ///
    /// - Parameters:
    ///   - authStatus: Filter groups by auth status.
    ///     If set, only groups with any of the provided auth statuses will be included.
    ///     If `nil`, the filter is not used.
    ///   - excludeBlockedContacts: Exclude groups with blocked leaders and last messages from
    ///     blocked contacts (defaults to `false`).
    ///   - excludeBannedContacts: Exclude groups with banned leaders and last messages from
    ///     banned contacts (defaults to `false`).
    public init(
      authStatus: Set<Group.AuthStatus>? = nil,
      excludeBlockedContacts: Bool = false,
      excludeBannedContacts: Bool = false
    ) {
      self.authStatus = authStatus
      self.excludeBlockedContacts = excludeBlockedContacts
      self.excludeBannedContacts = excludeBannedContacts
    }

    /// Filter groups by auth status
    ///
    /// If set, only groups with any of the provided auth statuses will be included.
    /// If `nil`, the filter is not used.
    public var authStatus: Set<Group.AuthStatus>?

    /// Exclude groups with blocked leaders and last messages from blocked contacts.
    public var excludeBlockedContacts: Bool

    /// Exclude groups with banned leaders and last messages from banned contacts.
    public var excludeBannedContacts: Bool
  }
}
