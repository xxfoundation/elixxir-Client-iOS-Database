import Foundation

public struct GroupMember: Equatable, Codable {
  public init(
    groupId: Group.ID,
    contactId: Contact.ID
  ) {
    self.groupId = groupId
    self.contactId = contactId
  }

  public var groupId: Group.ID
  public var contactId: Contact.ID
}

extension GroupMember {
  public typealias Save = (GroupMember) throws -> GroupMember
  public typealias Delete = (GroupMember) throws -> Bool
}
