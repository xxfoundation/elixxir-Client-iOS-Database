import GRDB
import XXModels

extension Group: PersistableRecord, FetchableRecord {
  enum Columns {
    static let id = Column("id")
    static let name = Column("name")
    static let leaderId = Column("leaderId")
    static let createdAt = Column("createdAt")
  }

  public static let databaseTableName: String = "groups"

  public static func request(_ query: Query, _ order: Order) -> QueryInterfaceRequest<Group> {
    var request = Group.all()

    // TODO: handle query

    switch order {
    case .name(desc: false):
      request = request.order(Columns.name)

    case .name(desc: true):
      request = request.order(Columns.name.desc)
    }

    return request
  }

  static let leader = belongsTo(
    Contact.self,
    key: "leader",
    using: .init([Columns.leaderId], to: [Contact.Columns.id])
  )

  static let groupMembers = hasMany(
    GroupMember.self,
    key: "groupMembers",
    using: .init([GroupMember.Columns.groupId], to: [Columns.id])
  )

  static let members = hasMany(
    Contact.self,
    through: groupMembers,
    using: GroupMember.contact,
    key: "members"
  )
}
