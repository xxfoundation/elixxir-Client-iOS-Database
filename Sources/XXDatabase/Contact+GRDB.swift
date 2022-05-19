import GRDB
import XXModels

extension Contact: FetchableRecord, PersistableRecord {
  enum Column: String, ColumnExpression {
    case id
    case marshaled
    case username
    case email
    case phone
    case nickname
  }

  public static let databaseTableName = "contacts"

  public static func request(_ query: Query, _ order: Order) -> QueryInterfaceRequest<Contact> {
    var request = Contact.all()

    // TODO: handle query

    switch order {
    case .username(desc: false):
      request = request.order(Column.username)

    case .username(desc: true):
      request = request.order(Column.username.desc)
    }

    return request
  }
}
