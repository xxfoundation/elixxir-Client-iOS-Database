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
  public typealias Fetch = (Query, Order) throws -> [GroupInfo]
  public typealias FetchPublisher = (Query, Order) -> AnyPublisher<[GroupInfo], Error>

  public struct Query: Equatable {
    public static let all = Query()

    public init() {}
  }

  public enum Order: Equatable {
    case groupName(desc: Bool = false)
  }
}
