import Combine
import Foundation

/// Represents aggregated info about a group
public struct GroupInfo: Identifiable, Equatable, Decodable {
  /// Unique identifier of a group info
  public typealias ID = Group.ID

  /// Instantiate aggregated info about a group
  /// 
  /// - Parameters:
  ///   - group: Group
  ///   - leader: Group leader's contact
  ///   - members: Array of group member contacts
  public init(
    group: Group,
    leader: Contact,
    members: [Contact]
  ) {
    self.group = group
    self.leader = leader
    self.members = members
  }

  /// Unique identifier of the group info
  ///
  /// Matches the group's ID
  public var id: Group.ID { group.id }

  /// Group
  public var group: Group

  /// Group leader's contact
  public var leader: Contact

  /// Array of group member contacts
  public var members: [Contact]
}

extension GroupInfo {
  /// Fetch group infos operation
  public typealias Fetch = XXModels.Fetch<GroupInfo, Query>

  /// Fetch group infos operation publisher
  public typealias FetchPublisher = XXModels.FetchPublisher<GroupInfo, Query>

  /// Query used for fetching group infos
  public struct Query: Equatable {
    /// Group infos sort order
    public enum SortOrder: Equatable {
      /// Sort by group name
      ///
      /// - Parameters:
      ///   - desc: Sort in descending order (defaults to `false`)
      case groupName(desc: Bool = false)
    }

    /// Instantiate query
    ///
    /// - Parameters:
    ///   - groupId: Group ID or `nil` for fetching all groups.
    ///   - sortBy: Sort order (defaults to `.groupName()`).
    public init(
      groupId: Group.ID? = nil,
      sortBy: SortOrder = .groupName()
    ) {
      self.groupId = groupId
      self.sortBy = sortBy
    }

    /// Group ID or `nil` for fetching all groups
    public var groupId: Group.ID?

    /// Group info sort order
    public var sortBy: SortOrder
  }
}
