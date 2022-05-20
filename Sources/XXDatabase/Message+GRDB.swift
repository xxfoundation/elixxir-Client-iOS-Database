import GRDB
import XXModels

extension Message: FetchableRecord, MutablePersistableRecord {
  enum Column: String, ColumnExpression {
    case id
    case networkId
    case senderId
    case recipientId
    case date
    case isUnread
    case text
  }

  public static let databaseTableName = "messages"

  public static func request(_ query: Query) -> QueryInterfaceRequest<Message> {
    var request = Message.all()

    switch query.chat {
    case .group(let groupId):
      request = request.filter(Column.recipientId == groupId)

    case .direct(let id1, let id2):
      request = request.filter(
        (Column.senderId == id1 && Column.recipientId == id2) ||
        (Column.senderId == id2 && Column.recipientId == id1)
      )
    }

    switch query.sortBy {
    case .date(desc: false):
      request = request.order(Column.date)

    case .date(desc: true):
      request = request.order(Column.date.desc)
    }

    return request
  }

  public mutating func didInsert(with rowID: Int64, for column: String?) {
    if column == Column.id.rawValue {
      id = rowID
    }
  }
}
