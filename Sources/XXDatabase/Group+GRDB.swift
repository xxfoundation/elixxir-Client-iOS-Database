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
}

