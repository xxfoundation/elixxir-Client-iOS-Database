import Combine
import Foundation

/// Represents group
public struct Group: Identifiable, Equatable, Codable {
  /// Unique identifier of a group
  public typealias ID = Data

  /// Instantiate group representation
  /// 
  /// - Parameters:
  ///   - id: Unique identifier of the group
  ///   - name: Group name
  ///   - leaderId: Group leader's contact ID
  ///   - createdAt: Group creation date
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

  /// Unique identifier of the group
  public var id: ID

  /// Group name
  public var name: String

  /// Group leader's contact ID
  public var leaderId: Contact.ID

  /// Group creation date
  public var createdAt: Date
}

extension Group {
  /// Fetch groups
  public typealias Fetch = XXModels.Fetch<Group, Query>

  /// Fetch groups - publisher
  public typealias FetchPublisher = XXModels.FetchPublisher<Group, Query>

  /// Save (insert new or update existing) group
  public typealias Save = XXModels.Save<Group>

  /// Save (insert new or update existing) group - publisher
  public typealias SavePublisher = XXModels.SavePublisher<Group>

  /// Delete group
  public typealias Delete = XXModels.Delete<Group>

  /// Delete group - publisher
  public typealias DeletePublisher = XXModels.DeletePublisher<Group>

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
    ///     If `true` - only include groups that have at least one message.
    ///     If `false` - only include groups that doesn't have messages.
    ///     If `nil` (default) - include groups with AND without messages.
    ///   - sortBy: Sort order
    public init(
      withMessages: Bool? = nil,
      sortBy: SortOrder
    ) {
      self.withMessages = withMessages
      self.sortBy = sortBy
    }

    /// Groups sort order
    public var sortBy: SortOrder

    /// Filter groups by messages
    ///
    /// If `true` - only include groups that have at least one message.
    /// If `false` - only include groups that doesn't have messages.
    /// If `nil` (default) - include groups with AND without messages.
    public var withMessages: Bool?
  }
}
