import Combine
import Foundation

/// Represents group
public struct Group: Identifiable, Equatable, Codable {
  /// Unique identifier of a group
  public typealias ID = Data

  /// Represents group authorization status
  public enum AuthStatus: String, Equatable, Codable {
    /// Invitation to the group received
    case pending

    /// Leaving the group
    case deleting

    /// Participating the group
    case participating

    /// Group invitation was hidden
    case hidden
  }

  /// Instantiate group representation
  /// 
  /// - Parameters:
  ///   - id: Unique identifier of the group
  ///   - name: Group name
  ///   - leaderId: Group leader's contact ID
  ///   - createdAt: Group creation date
  ///   - authStatus: Group authorization status
  public init(
    id: ID,
    name: String,
    leaderId: Contact.ID,
    createdAt: Date,
    authStatus: AuthStatus
  ) {
    self.id = id
    self.name = name
    self.leaderId = leaderId
    self.createdAt = createdAt
    self.authStatus = authStatus
  }

  /// Unique identifier of the group
  public var id: ID

  /// Group name
  public var name: String

  /// Group leader's contact ID
  public var leaderId: Contact.ID

  /// Group creation date
  public var createdAt: Date

  /// Group authorization status
  public var authStatus: AuthStatus
}

extension Group {
  /// Fetch groups operation
  public typealias Fetch = XXModels.Fetch<Group, Query>

  /// Fetch groups operation publisher
  public typealias FetchPublisher = XXModels.FetchPublisher<Group, Query>

  /// Save (insert new or update existing) group operation
  public typealias Save = XXModels.Save<Group>

  /// Delete group operation
  public typealias Delete = XXModels.Delete<Group>

  /// Query used for fetching groups
  public struct Query: Equatable {
    /// Groups sort order
    public enum SortOrder: Equatable {
      /// Sort by creation date
      ///
      /// - Parameters:
      ///   - desc: Sort in descending order (defaults to `false`)
      case createdAt(desc: Bool = false)
    }

    /// Instantiate query
    ///
    /// - Parameters:
    ///   - withMessages: Filter groups by messages.
    ///     If `true`, only groups that have at least one message will be fetched.
    ///     If `false`, only groups that don't have a message will be fetched.
    ///     If `nil` (default), the filter is not used.
    ///   - authStatus: Filter groups by auth status.
    ///     If set, only groups with any of the provided auth statuses will be fetched.
    ///     If `nil` (default), the filter is not used.
    ///   - sortBy: Sort order (defaults to `.createdAt(desc: true)`).
    public init(
      withMessages: Bool? = nil,
      authStatus: Set<AuthStatus>? = nil,
      sortBy: SortOrder = .createdAt(desc: true)
    ) {
      self.withMessages = withMessages
      self.authStatus = authStatus
      self.sortBy = sortBy
    }

    /// Filter groups by messages
    ///
    /// If `true`, only groups that have at least one message will be fetched.
    /// If `false`, only groups that don't have a message will be fetched.
    /// If `nil`, the filter is not used
    public var withMessages: Bool?

    /// Filter groups by auth status
    ///
    /// If set, only groups with any of the provided auth statuses will be fetched.
    /// If `nil`, the filter is not used.
    public var authStatus: Set<AuthStatus>?

    /// Groups sort order
    public var sortBy: SortOrder
  }
}
