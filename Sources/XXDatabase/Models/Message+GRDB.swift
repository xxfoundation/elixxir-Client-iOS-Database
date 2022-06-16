import GRDB
import XXModels

extension Message: FetchableRecord, MutablePersistableRecord {
  enum Column: String, ColumnExpression {
    case id
    case networkId
    case senderId
    case recipientId
    case groupId
    case date
    case status
    case isUnread
    case text
    case replyMessageId
    case roundURL
  }

  public static let databaseTableName = "messages"

  public static func request(_ query: Query) -> QueryInterfaceRequest<Message> {
    var request = Message.all()

    if let id = query.id {
      request = request.filter(id: id)
    }

    switch query.networkId {
    case .some(.some(let networkId)):
      request = request.filter(Column.networkId == networkId)

    case .some(.none):
      request = request.filter(Column.networkId == nil)

    case .none:
      break
    }

    switch query.chat {
    case .group(let groupId):
      request = request.filter(Column.groupId == groupId)

    case .direct(let id1, let id2):
      request = request.filter(
        (Column.senderId == id1 && Column.recipientId == id2) ||
        (Column.senderId == id2 && Column.recipientId == id1)
      )

    case .none:
      break
    }

    if let status = query.status {
      request = request.filter(Set(status.map(\.rawValue)).contains(Column.status))
    }

    if let isUnread = query.isUnread {
      request = request.filter(Column.isUnread == isUnread)
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
