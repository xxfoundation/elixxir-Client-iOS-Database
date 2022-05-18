import GRDB
import XXModels
import Combine

extension Contact: FetchableRecord, PersistableRecord {
  enum Columns {
    static let id = Column("id")
    static let marshaled = Column("marshaled")
    static let username = Column("username")
    static let email = Column("email")
    static let phone = Column("phone")
    static let nickname = Column("nickname")
  }

  public static let databaseTableName: String = "contacts"

  public static func request(_ query: Query, _ order: Order) -> QueryInterfaceRequest<Self> {
    var request = Self.all()

    // TODO: handle query

    switch order {
    case .username(desc: false):
      request = request.order(Columns.username)

    case .username(desc: true):
      request = request.order(Columns.username.desc)
    }

    return request
  }
}
