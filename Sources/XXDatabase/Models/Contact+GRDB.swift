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
    case photo
    case authStatus
    case isRecent
    case isBlocked
    case isBanned
    case createdAt
  }

  public static let databaseTableName = "contacts"

  static func request(_ query: Query) -> QueryInterfaceRequest<Contact> {
    var request = Contact.all()

    if let id = query.id {
      if id.count == 1, let id = id.first {
        request = request.filter(id: id)
      } else {
        request = request.filter(ids: id)
      }
    }

    switch query.username {
    case .some(.some(let username)):
      request = request.filter(Column.username == username)

    case .some(.none):
      request = request.filter(Column.username == nil)

    case .none:
      break
    }

    if let text = query.text {
      let columns = [Column.username, Column.email, Column.phone, Column.nickname]
      let escape = #"\"#
      let escapedText = text.replacingOccurrences(of: "%", with: "\(escape)%")
      let pattern = "%\(escapedText)%"
      request = request.filter(columns
        .map { $0.like(pattern, escape: escape) }
        .joined(operator: .or)
      )
    }

    if let authStatus = query.authStatus {
      request = request.filter(Set(authStatus.map(\.rawValue)).contains(Column.authStatus))
    }

    if let isRecent = query.isRecent {
      request = request.filter(Column.isRecent == isRecent)
    }

    if let isBlocked = query.isBlocked {
      request = request.filter(Column.isBlocked == isBlocked)
    }

    if let isBanned = query.isBanned {
      request = request.filter(Column.isBanned == isBanned)
    }

    switch query.sortBy {
    case .username(desc: false):
      request = request.order(Column.username)

    case .username(desc: true):
      request = request.order(Column.username.desc)

    case .createdAt(desc: false):
      request = request.order(Column.createdAt)

    case .createdAt(desc: true):
      request = request.order(Column.createdAt.desc)
    }

    return request
  }

  static func columnAssignments(_ assignments: Assignments) -> [ColumnAssignment] {
    var columnAssignments: [ColumnAssignment] = []

    if let authStatus = assignments.authStatus {
      columnAssignments.append(Column.authStatus.set(to: authStatus.rawValue))
    }

    return columnAssignments
  }
}
