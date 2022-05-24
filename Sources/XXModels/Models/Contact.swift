import Combine
import Foundation

public struct Contact: Identifiable, Equatable, Codable {
  public typealias ID = Data

  public init(
    id: ID,
    marshaled: Data? = nil,
    username: String? = nil,
    email: String? = nil,
    phone: String? = nil,
    nickname: String? = nil
  ) {
    self.id = id
    self.marshaled = marshaled
    self.username = username
    self.email = email
    self.phone = phone
    self.nickname = nickname
  }

  public var id: ID
  public var marshaled: Data?
  public var username: String?
  public var email: String?
  public var phone: String?
  public var nickname: String?
}

extension Contact {
  public typealias Fetch = XXModels.Fetch<Contact, Query>
  public typealias FetchPublisher = XXModels.FetchPublisher<Contact, Query>
  public typealias Insert = XXModels.Insert<Contact>
  public typealias InsertPublisher = XXModels.InsertPublisher<Contact>
  public typealias Update = XXModels.Update<Contact>
  public typealias UpdatePublisher = XXModels.UpdatePublisher<Contact>
  public typealias Save = XXModels.Save<Contact>
  public typealias SavePublisher = XXModels.SavePublisher<Contact>
  public typealias Delete = XXModels.Delete<Contact>
  public typealias DeletePublisher = XXModels.DeletePublisher<Contact>

  public struct Query: Equatable {
    public enum SortOrder: Equatable {
      case username(desc: Bool = false)
    }

    public init(sortBy: SortOrder) {
      self.sortBy = sortBy
    }

    public var sortBy: SortOrder
  }
}
