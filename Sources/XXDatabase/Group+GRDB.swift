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

  public static func request(_ query: Query) -> QueryInterfaceRequest<Group> {
    var request = Group.all()

    switch query.sortBy {
    case .createdAt(desc: false):
      request = request.order(Column.createdAt)

    case .createdAt(desc: true):
      request = request.order(Column.createdAt.desc)
    }

    return request
  }
}
