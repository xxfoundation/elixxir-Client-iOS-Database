import Foundation
import GRDB

struct Contact: Identifiable, Equatable, Codable {
  var id: Data
  var marshaled: Data?
  var username: String?
  var email: String?
  var phone: String?
  var nickname: String?
}

extension Contact: FetchableRecord, PersistableRecord {
  enum Columns {
    static let id = Column(CodingKeys.id)
    static let marshaled = Column(CodingKeys.marshaled)
    static let username = Column(CodingKeys.username)
    static let email = Column(CodingKeys.email)
    static let phone = Column(CodingKeys.phone)
    static let nickname = Column(CodingKeys.nickname)
  }

  struct Query: Equatable {
    init() {}
  }

  enum Order: Equatable {
    case username(desc: Bool = false)
  }

  static let databaseTableName: String = "contacts"

  static func request(query: Query, order: Order) -> QueryInterfaceRequest<Self> {
    var request = Self.all()

    // TODO: handle query

    switch order {
    case .username(let desc):
      let column = Columns.username
      request = request.order(desc ? column.desc : column)
    }

    return request
  }
}
