import Combine
import Foundation

public struct Group: Identifiable, Equatable, Codable {
  public typealias ID = Data

  public init(
    id: ID,
    name: String,
    leaderId: Contact.ID,
    createdAt: Date
  ) {
    self.id = id
    self.name = name
    self.leaderId = leaderId
    self.createdAt = createdAt
  }

  public var id: ID
  public var name: String
  public var leaderId: Contact.ID
  public var createdAt: Date
}

extension Group {
  public typealias Fetch = XXModels.Fetch<Group, Query>
  public typealias FetchPublisher = XXModels.FetchPublisher<Group, Query>
  public typealias Save = XXModels.Save<Group>
  public typealias SavePublisher = XXModels.SavePublisher<Group>
  public typealias Delete = XXModels.Delete<Group>
  public typealias DeletePublisher = XXModels.DeletePublisher<Group>

  public struct Query: Equatable {
    public enum SortOrder: Equatable {
      case createdAt(desc: Bool = false)
    }

    public init(
      withMessages: Bool? = nil,
      sortBy: SortOrder
    ) {
      self.withMessages = withMessages
      self.sortBy = sortBy
    }

    public var sortBy: SortOrder
    public var withMessages: Bool?
  }
}
