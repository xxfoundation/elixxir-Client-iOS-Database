import Foundation

public struct GroupMember: Equatable, Codable {
  public init(
    groupId: Data,
    contactId: Data
  ) {
    self.groupId = groupId
    self.contactId = contactId
  }

  public var groupId: Data
  public var contactId: Data
}

extension GroupMember {
  public typealias Save = (GroupMember) throws -> GroupMember
  public typealias Delete = (GroupMember) throws -> Bool
}
