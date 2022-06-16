import GRDB
import XXModels

extension FileTransfer: FetchableRecord, MutablePersistableRecord {
  enum Column: String, ColumnExpression {
    case id
    case contactId
    case name
    case type
    case data
    case progress
    case isIncoming
    case createdAt
  }

  public static let databaseTableName = "fileTransfers"

  public static func request(_ query: Query) -> QueryInterfaceRequest<FileTransfer> {
    var request = FileTransfer.all()

    if let id = query.id {
      if id.count == 1, let id = id.first {
        request = request.filter(id: id)
      } else {
        request = request.filter(ids: id)
      }
    }

    if let contactId = query.contactId {
      request = request.filter(Column.contactId == contactId)
    }

    if let isIncoming = query.isIncoming {
      request = request.filter(Column.isIncoming == isIncoming)
    }

    switch query.sortBy {
    case .createdAt(desc: false):
      request = request.order(Column.createdAt)

    case .createdAt(desc: true):
      request = request.order(Column.createdAt.desc)
    }

    return request
  }
}
