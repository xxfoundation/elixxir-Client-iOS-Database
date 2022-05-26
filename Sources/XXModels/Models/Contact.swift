import Combine
import Foundation

/// Represents contact
public struct Contact: Identifiable, Equatable, Codable {
  /// Unique identifier of a contact
  public typealias ID = Data

  /// Instantiate contact representation
  ///
  /// - Parameters:
  ///   - id: Unique identifier
  ///   - marshaled: Marshaled contact data
  ///   - username: Contact username
  ///   - email: Contact email address
  ///   - phone: Contact phone number
  ///   - nickname: Contact nickname
  ///   - connected: Boolean value indicating if secure channel connection was established with
  ///     the contact
  public init(
    id: ID,
    marshaled: Data? = nil,
    username: String? = nil,
    email: String? = nil,
    phone: String? = nil,
    nickname: String? = nil,
    connected: Bool
  ) {
    self.id = id
    self.marshaled = marshaled
    self.username = username
    self.email = email
    self.phone = phone
    self.nickname = nickname
    self.connected = connected
  }

  /// Unique identifier
  public var id: ID

  /// Marshaled contact data
  public var marshaled: Data?

  /// Contact username
  public var username: String?

  /// Contact email address
  public var email: String?

  /// Contact phone number
  public var phone: String?

  /// Contact nickname
  public var nickname: String?

  /// Boolean value indicating if secure channel connection was established with the contact
  public var connected: Bool
}

extension Contact {
  /// Fetch contacts operation
  public typealias Fetch = XXModels.Fetch<Contact, Query>

  /// Fetch contacts operation publisher
  public typealias FetchPublisher = XXModels.FetchPublisher<Contact, Query>

  /// Insert new contact operation
  public typealias Insert = XXModels.Insert<Contact>

  /// Insert new contact operation publisher
  public typealias InsertPublisher = XXModels.InsertPublisher<Contact>

  /// Update existing contact operation
  public typealias Update = XXModels.Update<Contact>

  /// Update existing contact operation publisher
  public typealias UpdatePublisher = XXModels.UpdatePublisher<Contact>

  /// Save (insert new or update existing) contact operation
  public typealias Save = XXModels.Save<Contact>

  /// Save (insert new or update existing) contact operation publisher
  public typealias SavePublisher = XXModels.SavePublisher<Contact>

  /// Delete contact operation
  public typealias Delete = XXModels.Delete<Contact>

  /// Delete contact operation publisher
  public typealias DeletePublisher = XXModels.DeletePublisher<Contact>

  /// Query used for fetching contacts
  public struct Query: Equatable {
    /// Contacts sort order
    public enum SortOrder: Equatable {
      /// Sort by username
      ///
      /// - Parameters:
      ///   - desc: Sort in descending order (defaults to `false`)
      case username(desc: Bool = false)
    }

    /// Instantiate contacts query
    ///
    /// - Parameters:
    ///   - connected: Filter contacts with connected status.
    ///     If set to `true`, only contacts with `connected` status will be fetched.
    ///     If set to `false`, only contacts without `connected` status will be fetched.
    ///     If `nil` (default), the filter is not used.
    ///   - sortBy: Sort order
    public init(
      connected: Bool? = nil,
      sortBy: SortOrder
    ) {
      self.sortBy = sortBy
      self.connected = connected
    }

    /// Contacts sort order
    public var sortBy: SortOrder

    /// Filter contacts with connected status
    ///
    /// If set to `true`, only contacts with `connected` status will be fetched.
    /// If set to `false`, only contacts without `connected` status will be fetched.
    /// If `nil`, the filter is not used.
    public var connected: Bool?
  }
}
