import GRDB
import XXModels

extension ContactChatInfo: FetchableRecord {
  enum Column: String, ColumnExpression {
    case contact
    case lastMessage
    case unreadCount
  }

  public static func request(_ query: Query) -> AdaptedFetchRequest<SQLRequest<ContactChatInfo>> {
    SQLRequest(
      sql: """
        SELECT
          -- All contact columns:
          c2.*,
          -- Unread messages count column:
          0 AS unreadCount,
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
          c1.id = :userId
        GROUP BY
          c2.id
        ORDER BY
          date DESC;
        """,
      arguments: [
        "userId": query.userId
      ]
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
