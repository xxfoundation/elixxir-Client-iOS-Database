import GRDB
import XXModels

extension GroupChatInfo: FetchableRecord {
  enum Column: String, ColumnExpression {
    case group
    case lastMessage
    case unreadCount
  }

  public static func request(_ query: Query) -> AdaptedFetchRequest<SQLRequest<GroupChatInfo>> {
    SQLRequest(sql: """
      SELECT
        -- All group columns:
        g.*,
        -- Unread messages count column:
        COUNT(CASE WHEN m.isUnread THEN 1 END) AS unreadCount,
        -- All message columns:
        m.*,
        -- Latest message date column:
        MAX(m.date) AS date
      FROM
        messages m
      INNER JOIN groups g
        ON g.id = m.groupId
      GROUP BY
        g.id
      ORDER BY
        date DESC;
      """
    )
    .adapted { db in
      let adapters = try splittingRowAdapters(columnCounts: [
        Group.numberOfSelectedColumns(db), // all group columns
        1, // unread messages count column
      ])
      return ScopeAdapter([
        Column.group.rawValue: adapters[0],
        Column.unreadCount.rawValue: adapters[1],
        Column.lastMessage.rawValue: adapters[2],
      ])
    }
  }
}
