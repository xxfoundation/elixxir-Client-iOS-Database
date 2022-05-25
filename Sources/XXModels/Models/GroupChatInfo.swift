import Combine

/// Represents chat within a group
public struct GroupChatInfo: Identifiable, Equatable, Codable {
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
    public init() {}
  }
}
