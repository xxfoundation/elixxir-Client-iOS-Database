import GRDB
import XXModels

extension Group: PersistableRecord, FetchableRecord {
  enum Column: String, ColumnExpression {
    case id
    case name
    case leaderId
    case createdAt
  }

  enum Association {
    static let leader = belongsTo(
      Contact.self,
      using: .init([Column.leaderId], to: [Contact.Column.id])
    )

    static let groupMembers = hasMany(
      GroupMember.self,
      using: .init([GroupMember.Column.groupId], to: [Column.id])
    )

    static let members = hasMany(
      Contact.self,
      through: groupMembers,
      using: GroupMember.Association.contact
    )
  }

  public static let databaseTableName = "groups"
}
