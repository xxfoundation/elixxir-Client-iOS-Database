import Combine
import Foundation

/// Represents chat within a group or with a contact
public enum ChatInfo: Identifiable, Equatable, Codable {
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
    /// - Parameters:
    ///   - userId: Current user's contact ID
    public init(userId: Contact.ID) {
      self.userId = userId
    }

    /// Current user's contact ID
    public var userId: Contact.ID
  }
}
