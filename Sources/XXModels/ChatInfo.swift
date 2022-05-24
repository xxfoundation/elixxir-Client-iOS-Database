import Combine
import Foundation

public enum ChatInfo: Identifiable, Equatable, Codable {
  public enum ID: Hashable {
    case contactChat(ContactChatInfo.ID)
    case groupChat(GroupChatInfo.ID)
    case group(Group.ID)
  }

  case contactChat(ContactChatInfo)
  case groupChat(GroupChatInfo)
  case group(Group)

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
  public typealias Fetch = (Query) throws -> [ChatInfo]
  public typealias FetchPublisher = (Query) -> AnyPublisher<[ChatInfo], Error>

  public struct Query: Equatable {
    public init(userId: Contact.ID) {
      self.userId = userId
    }

    public var userId: Contact.ID
  }
}
