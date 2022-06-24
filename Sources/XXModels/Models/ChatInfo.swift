import Foundation

/// Represents chat within a group or with a contact
public enum ChatInfo: Identifiable, Equatable, Hashable, Codable {
  /// Unique identifier of a chat
  public enum ID: Hashable {
    /// Identifier of direct chat with a contact
    case contactChat(ContactChatInfo.ID)

    /// Identifier of group chat
    case groupChat(GroupChatInfo.ID)

    /// Identifier of a group without messages
    case group(Group.ID)
  }

  /// Chat with a contact
  case contactChat(ContactChatInfo)

  /// Chat within a group
  case groupChat(GroupChatInfo)

  /// A group without exchanged messages
  case group(Group)

  /// Unique identifier of the chat
  public var id: ID {
    switch self {
    case .contactChat(let info):
      return .contactChat(info.id)
    case .groupChat(let info):
      return .groupChat(info.id)
    case .group(let group):
      return .group(group.id)
    }
  }

  /// Chat date
  ///
  /// For direct and group chats it's a date of the last message.
  /// For group without messages it's a group creation date.
  public var date: Date {
    switch self {
    case .contactChat(let info):
      return info.lastMessage.date
    case .groupChat(let info):
      return info.lastMessage.date
    case .group(let group):
      return group.createdAt
    }
  }
}

extension ChatInfo {
  /// Fetch chat infos operation
  public typealias Fetch = XXModels.Fetch<ChatInfo, Query>

  /// Fetch chat infos operation publisher
  public typealias FetchPublisher = XXModels.FetchPublisher<ChatInfo, Query>

  /// Query used for fetching chat infos
  public struct Query: Equatable {
    /// Instantiate chat info query
    ///
    /// Results are sorted by `ChatInfo.date` in descending order.
    ///
    /// - Parameters:
    ///   - contactChatInfoQuery: Direct chat infos query.
    ///     If `nil`, exclude direct chats from results.
    ///   - groupChatInfoQuery: Group chat infos query.
    ///     If `nil`, exclude group chats from results.
    ///   - groupQuery: Groups query.
    ///     If `nil`, exclude groups results.
    public init(
      contactChatInfoQuery: ContactChatInfo.Query?,
      groupChatInfoQuery: GroupChatInfo.Query?,
      groupQuery: Group.Query?
    ) {
      self.contactChatInfoQuery = contactChatInfoQuery
      self.groupChatInfoQuery = groupChatInfoQuery
      self.groupQuery = groupQuery
    }

    /// Direct chats query
    ///
    /// If `nil`, exclude direct chats from results.
    public var contactChatInfoQuery: ContactChatInfo.Query?

    /// Group chats query
    ///
    /// If `nil`, exclude group chats from results.
    public var groupChatInfoQuery: GroupChatInfo.Query?

    /// Groups query
    ///
    /// If `nil`, exclude groups results.
    public var groupQuery: Group.Query?
  }
}
