import Combine
import Foundation

public struct Message: Identifiable, Equatable, Codable {
  public init(
    id: Int64? = nil,
    networkId: Data? = nil,
    senderId: Data,
    recipientId: Data,
    date: Date,
    isUnread: Bool,
    text: String
  ) {
    self.id = id
    self.networkId = networkId
    self.senderId = senderId
    self.recipientId = recipientId
    self.date = date
    self.isUnread = isUnread
    self.text = text
  }

  public var id: Int64?
  public var networkId: Data?
  public var senderId: Data
  public var recipientId: Data
  public var date: Date
  public var isUnread: Bool
  public var text: String
}

extension Message {
  public typealias Fetch = (Query, Order) throws -> [Message]
  public typealias FetchPublisher = (Query, Order) -> AnyPublisher<[Message], Error>
  public typealias Save = (Message) throws -> Message
  public typealias SavePublisher = (Message) -> AnyPublisher<Message, Error>
  public typealias Delete = (Message) throws -> Bool
  public typealias DeletePublisher = (Message) -> AnyPublisher<Bool, Error>

  public struct Query: Equatable {
    public static func directChat(contactIds id1: Data, _ id2: Data) -> Query {
      Query(chat: .direct(id1, id2))
    }

    public static func groupChat(groupId: Data) -> Query {
      Query(chat: .group(groupId))
    }

    public enum Chat: Equatable {
      case direct(Data, Data)
      case group(Data)
    }

    public var chat: Chat
  }

  public enum Order: Equatable {
    case date(desc: Bool = false)
  }
}
