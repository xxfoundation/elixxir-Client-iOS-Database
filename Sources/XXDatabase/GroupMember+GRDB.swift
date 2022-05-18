import GRDB
import XXModels

extension GroupMember: FetchableRecord, PersistableRecord {
  enum Columns {
    static let groupId = Column("groupId")
    static let contactId = Column("contactId")
  }

  public static let databaseTableName = "groupMembers"

  static let group = belongsTo(
    Group.self,
    key: "group",
    using: .init([Columns.groupId], to: [Group.Columns.id])
  )

  static let contact = belongsTo(
    Contact.self,
    key: "contact",
    using: .init([Columns.contactId], to: [Contact.Columns.id])
  )
}
