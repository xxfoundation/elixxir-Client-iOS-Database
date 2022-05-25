import GRDB
import XXModels

extension GroupMember: FetchableRecord, PersistableRecord {
  enum Column: String, ColumnExpression {
    case groupId
    case contactId
  }

  enum Association {
    static let group = belongsTo(
      Group.self,
      using: .init([Column.groupId], to: [Group.Column.id])
    )

    static let contact = belongsTo(
      Contact.self,
      using: .init([Column.contactId], to: [Contact.Column.id])
    )
  }

  public static let databaseTableName = "groupMembers"
}
