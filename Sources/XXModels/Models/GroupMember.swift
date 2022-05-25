import Foundation

/// Represents a group-member relation
public struct GroupMember: Equatable, Codable {
  /// Instantiate group-member relation
  /// 
  /// - Parameters:
  ///   - groupId: Group ID
  ///   - contactId: Member's contact ID
  public init(
    groupId: Group.ID,
    contactId: Contact.ID
  ) {
    self.groupId = groupId
    self.contactId = contactId
  }

  /// Group ID
  public var groupId: Group.ID

  // Member's contact ID
  public var contactId: Contact.ID
}

extension GroupMember {
  /// Save group-member relation
  public typealias Save = XXModels.Save<GroupMember>

  /// Delete group-member relation
  public typealias Delete = XXModels.Delete<GroupMember>
}
