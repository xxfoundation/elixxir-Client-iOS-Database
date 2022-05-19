import Combine
import Foundation

public struct Group: Identifiable, Equatable, Codable {
  public init(
    id: Data,
    name: String,
    leaderId: Data,
    createdAt: Date
  ) {
    self.id = id
    self.name = name
    self.leaderId = leaderId
    self.createdAt = createdAt
  }

  public var id: Data
  public var name: String
  public var leaderId: Data
  public var createdAt: Date
}

extension Group {
  public typealias Fetch = (Query, Order) throws -> [Group]
  public typealias FetchPublisher = (Query, Order) -> AnyPublisher<[Group], Error>
  public typealias Insert = (Group) throws -> Group
  public typealias InsertPublisher = (Group) -> AnyPublisher<Group, Error>
  public typealias Update = (Group) throws -> Group
  public typealias UpdatePublisher = (Group) -> AnyPublisher<Group, Error>
  public typealias Save = (Group) throws -> Group
  public typealias SavePublisher = (Group) -> AnyPublisher<Group, Error>
  public typealias Delete = (Group) throws -> Bool
  public typealias DeletePublisher = (Group) -> AnyPublisher<Bool, Error>

  public struct Query: Equatable {
    public static let all = Query()
  }

  public enum Order: Equatable {
    case name(desc: Bool = false)
  }
}
