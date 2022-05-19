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
      key: "leader",
      using: .init([Column.leaderId], to: [Contact.Column.id])
    )

    static let groupMembers = hasMany(
      GroupMember.self,
      key: "groupMembers",
      using: .init([GroupMember.Column.groupId], to: [Column.id])
    )

    static let members = hasMany(
      Contact.self,
      through: groupMembers,
      using: GroupMember.Association.contact,
      key: "members"
    )
  }

  public static let databaseTableName = "groups"

  public static func request(_ query: Query, _ order: Order) -> QueryInterfaceRequest<Group> {
    var request = Group.all()

    // TODO: handle query

    switch order {
    case .name(desc: false):
      request = request.order(Column.name)

    case .name(desc: true):
      request = request.order(Column.name.desc)
    }

    return request
  }
}
