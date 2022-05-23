import Combine
import Foundation

public enum ChatInfo: Identifiable, Equatable, Codable {
  public enum ID: Hashable {
    case contact(ContactChatInfo.ID)
    case group(GroupChatInfo.ID)
  }

  case contact(ContactChatInfo)
  case group(GroupChatInfo)

  public var id: ID {
    switch self {
    case .contact(let info):
      return .contact(info.id)
    case .group(let info):
      return .group(info.id)
    }
  }

  public var lastMessage: Message {
    switch self {
    case .contact(let info):
      return info.lastMessage
    case .group(let info):
      return info.lastMessage
    }
  }

  public var unreadCount: Int {
    switch self {
    case .contact(let info):
      return info.unreadCount
    case .group(let info):
      return info.unreadCount
    }
  }
}

extension ChatInfo {
  public typealias Fetch = (Query) throws -> [ChatInfo]
  public typealias FetchPublisher = (Query) -> AnyPublisher<[ChatInfo], Error>

  public struct Query: Equatable {
    public init(userId: Contact.ID) {
      self.userId = userId
    }

    public var userId: Contact.ID
  }
}
