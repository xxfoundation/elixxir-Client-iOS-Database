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
    case authorized
    case authRequest
  }

  public static let databaseTableName = "contacts"

  public static func request(_ query: Query) -> QueryInterfaceRequest<Contact> {
    var request = Contact.all()

    if let authorized = query.authorized {
      request = request.filter(Column.authorized == authorized)
    }

    if let authRequest = query.authRequest {
      request = request.filter(Column.authRequest == authRequest.rawValue)
    }

    switch query.sortBy {
    case .username(desc: false):
      request = request.order(Column.username)

    case .username(desc: true):
      request = request.order(Column.username.desc)
    }

    return request
  }
}
