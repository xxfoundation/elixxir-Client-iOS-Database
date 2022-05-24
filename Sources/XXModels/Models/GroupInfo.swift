import Combine
import Foundation

public struct GroupInfo: Identifiable, Equatable, Decodable {
  public init(
    group: Group,
    leader: Contact,
    members: [Contact]
  ) {
    self.group = group
    self.leader = leader
    self.members = members
  }

  public var id: Group.ID { group.id }
  public var group: Group
  public var leader: Contact
  public var members: [Contact]
}

extension GroupInfo {
  public typealias Fetch = XXModels.Fetch<GroupInfo, Query>
  public typealias FetchPublisher = XXModels.FetchPublisher<GroupInfo, Query>

  public struct Query: Equatable {
    public enum SortOrder: Equatable {
      case groupName(desc: Bool = false)
    }

    public init(
      groupId: Group.ID? = nil,
      sortBy: SortOrder
    ) {
      self.groupId = groupId
      self.sortBy = sortBy
    }

    public var groupId: Group.ID?
    public var sortBy: SortOrder
  }
}
