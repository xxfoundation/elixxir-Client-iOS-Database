import GRDB
import XXModels

extension ContactChatInfo: FetchableRecord {
  enum Column: String, ColumnExpression {
    case contact
    case lastMessage
    case unreadCount
  }

  static func request(_ query: Query) -> AdaptedFetchRequest<SQLRequest<ContactChatInfo>> {
    var sqlWhere: [String] = ["c1.id = :userId"]
    var sqlArguments: StatementArguments = ["userId": query.userId]

    if let authStatus = query.authStatus {
      sqlWhere.append("AND \(sqlWhereAuthStatus(count: authStatus.count))")
      _ = sqlArguments.append(contentsOf: sqlArgumentsAuthStatus(authStatus))
    }

    if let isBlocked = query.isBlocked {
      sqlWhere.append("AND c2.isBlocked = :isBlocked")
      _ = sqlArguments.append(contentsOf: StatementArguments(["isBlocked": isBlocked]))
    }

    if let isBanned = query.isBanned {
      sqlWhere.append("AND c2.isBanned = :isBanned")
      _ = sqlArguments.append(contentsOf: StatementArguments(["isBanned": isBanned]))
    }

    let sql = """
      SELECT
        -- All contact columns:
        c2.*,
        -- Unread messages count column:
        COUNT(CASE WHEN m.isUnread THEN 1 END) AS unreadCount,
        -- All message columns:
        m.*,
        -- Latest message date column:
        MAX(m.date) AS date
      FROM
        messages m
      INNER JOIN contacts c1
        ON c1.id IN (m.senderId, m.recipientId)
      INNER JOIN contacts c2
        ON c2.id IN (m.senderId, m.recipientId)
        AND c1.id <> c2.id
      WHERE
        \(sqlWhere.joined(separator: "\n  "))
      GROUP BY
        c2.id
      ORDER BY
        date DESC;
      """

    return SQLRequest(
      sql: sql,
      arguments: sqlArguments
    )
    .adapted { db in
      let adapters = try splittingRowAdapters(columnCounts: [
        Contact.numberOfSelectedColumns(db), // all contact columns
        1, // unread messages count column
      ])
      return ScopeAdapter([
        ContactChatInfo.Column.contact.rawValue: adapters[0],
        ContactChatInfo.Column.unreadCount.rawValue: adapters[1],
        ContactChatInfo.Column.lastMessage.rawValue: adapters[2],
      ])
    }
  }

  private static func sqlWhereAuthStatus(count: Int) -> String {
    let arguments = (0..<count).map { ":authStatus\($0)" }.joined(separator: ", ")
    return "c2.authStatus IN (\(arguments))"
  }

  private static func sqlArgumentsAuthStatus(
    _ statuses: Set<Contact.AuthStatus>
  ) -> StatementArguments {
    StatementArguments(statuses.enumerated().reduce(into: [:]) {
      $0["authStatus\($1.offset)"] = $1.element.rawValue
    })
  }
}
