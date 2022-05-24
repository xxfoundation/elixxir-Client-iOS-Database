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
  public typealias Save = XXModels.Save<GroupMember>
  public typealias Delete = XXModels.Delete<GroupMember>
}
