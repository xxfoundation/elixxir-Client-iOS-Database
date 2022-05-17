import Foundation
import GRDB

struct Group: Identifiable, Equatable, Codable {
  var id: Data
  var name: String
  var leaderId: Data
  var createdAt: Date
}

extension Group: PersistableRecord {
  enum Columns {
    static let id = Column(CodingKeys.id)
    static let name = Column(CodingKeys.name)
    static let leaderId = Column(CodingKeys.leaderId)
    static let createdAt = Column(CodingKeys.createdAt)
  }

  static let databaseTableName: String = "groups"

  static let leader = belongsTo(
    Contact.self,
    key: "leader",
    using: .init(
      [Columns.leaderId],
      to: [Contact.Columns.id]
    )
  )

  static let groupMembers = hasMany(
    GroupMember.self,
    key: "groupMembers",
    using: .init(
      [GroupMember.Columns.groupId],
      to: [Columns.id]
    )
  )

  static let members = hasMany(
    Contact.self,
    through: groupMembers,
    using: GroupMember.contact,
    key: "members"
  )
}
