import GRDB
import XXModels

extension ContactChatInfo: FetchableRecord {
  enum Column: String, ColumnExpression {
    case contact
    case lastMessage
    case unreadCount
  }

  static func request(_ query: Query) -> AdaptedFetchRequest<SQLRequest<ContactChatInfo>> {
    var whereQuery: [String] = ["c1.id = :userId"]
    var arguments: StatementArguments = ["userId": query.userId]

    if let authStatus = query.authStatus {
      let authStatusArgumentNames = (0..<authStatus.count).map { ":authStatus\($0)" }
      whereQuery.append("c2.authStatus IN (\(authStatusArgumentNames.joined(separator: ", ")))")
      authStatus.enumerated().forEach { index, status in
        _ = arguments.append(contentsOf: ["authStatus\(index)": status.rawValue])
      }
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
        \(whereQuery.joined(separator: "\n  AND "))
      GROUP BY
        c2.id
      ORDER BY
        date DESC;
      """

    return SQLRequest(
      sql: sql,
      arguments: arguments
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
}
