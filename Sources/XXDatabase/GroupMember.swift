import GRDB
import Foundation

struct GroupMember: Equatable, Codable {
  var groupId: Data
  var contactId: Data
}

extension GroupMember: PersistableRecord {
  enum Columns {
    static let groupId = Column(CodingKeys.groupId)
    static let contactId = Column(CodingKeys.contactId)
  }

  static let databaseTableName = "groupMembers"

  static let group = belongsTo(
    Group.self,
    key: "group",
    using: .init(
      [Columns.groupId],
      to: [Group.Columns.id]
    )
  )

  static let contact = belongsTo(
    Contact.self,
    key: "contact",
    using: .init(
      [Columns.contactId],
      to: [Contact.Columns.id]
    )
  )
}
