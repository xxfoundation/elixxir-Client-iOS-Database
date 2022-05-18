import GRDB
import XXModels

extension GroupMember: FetchableRecord, PersistableRecord {
  enum Columns {
    static let groupId = Column("groupId")
    static let contactId = Column("contactId")
  }

  public static let databaseTableName = "groupMembers"
}

