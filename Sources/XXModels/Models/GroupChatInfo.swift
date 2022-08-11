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
    ///   - isLeaderBlocked: Filter by leader contact's `isBlocked` status.
    ///     If `true`, only groups with blocked leader contacts are included.
    ///     If `false`, only groups with non-blocked contacts are included.
    ///     If `nil` (default), the filter is not used.
    ///   - isLeaderBanned: Filter by leader contact's `isBlocked` status.
    ///     If `true`, only groups with blocked leader contacts are included.
    ///     If `false`, only groups with non-blocked contacts are included.
    ///     If `nil` (default), the filter is not used.
    ///   - excludeBlockedContactsMessages: Exclude messages from blocked contacts
    ///     (defaults to `false`).
    ///   - excludeBannedContactsMessages: Exclude messages from banned contacts
    ///     (defaults to `false`).
    public init(
      authStatus: Set<Group.AuthStatus>? = nil,
      isLeaderBlocked: Bool? = nil,
      isLeaderBanned: Bool? = nil,
      excludeBlockedContactsMessages: Bool = false,
      excludeBannedContactsMessages: Bool = false
    ) {
      self.authStatus = authStatus
      self.isLeaderBlocked = isLeaderBlocked
      self.isLeaderBanned = isLeaderBanned
      self.excludeBlockedContactsMessages = excludeBlockedContactsMessages
      self.excludeBannedContactsMessages = excludeBannedContactsMessages
    }

    /// Filter groups by auth status
    ///
    /// If set, only groups with any of the provided auth statuses will be included.
    /// If `nil`, the filter is not used.
    public var authStatus: Set<Group.AuthStatus>?

    /// Filter by leader contact's `isBlocked` status
    ///
    /// If `true`, only groups with blocked leader contacts are included.
    /// If `false`, only groups with non-blocked contacts are included.
    /// If `nil`, the filter is not used.
    public var isLeaderBlocked: Bool?

    /// Filter by leader contact's `isBanned` status
    ///
    /// If `true`, only groups with banned leader contacts are included.
    /// If `false`, only groups with non-banned leader contacts are included.
    /// If `nil`, the filter is not used.
    public var isLeaderBanned: Bool?

    /// Exclude messages from blocked contacts.
    public var excludeBlockedContactsMessages: Bool

    /// Exclude messages from banned contacts.
    public var excludeBannedContactsMessages: Bool
  }
}
