import GRDB
import XXModels

extension GroupChatInfo: FetchableRecord {
  enum Column: String, ColumnExpression {
    case group
    case lastMessage
    case unreadCount
  }

  static func request(_ query: Query) -> AdaptedFetchRequest<SQLRequest<GroupChatInfo>> {
    var sqlWhere: [String] = []
    var sqlArguments: StatementArguments = [:]

    if let authStatus = query.authStatus {
      sqlWhere.append(sqlWhereAuthStatus(count: authStatus.count))
      _ = sqlArguments.append(contentsOf: sqlArgumentsAuthStatus(authStatus))
    }

    let sql = """
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
      \(sqlWhere.isEmpty ? "" : "WHERE\n  \(sqlWhere.joined(separator: "\n  "))")
      GROUP BY
        g.id
      ORDER BY
        date DESC;
      """

    return SQLRequest(
      sql: sql,
      arguments: sqlArguments
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

  private static func sqlWhereAuthStatus(count: Int) -> String {
    let arguments = (0..<count).map { ":authStatus\($0)" }.joined(separator: ", ")
    return "g.authStatus IN (\(arguments))"
  }

  private static func sqlArgumentsAuthStatus(
    _ statuses: Set<Group.AuthStatus>
  ) -> StatementArguments {
    StatementArguments(statuses.enumerated().reduce(into: [:]) {
      $0["authStatus\($1.offset)"] = $1.element.rawValue
    })
  }
}
