import GRDB
import XXModels

extension GroupChatInfo: FetchableRecord {
  enum Column: String, ColumnExpression {
    case group
    case lastMessage
    case unreadCount
  }

  static func request(_ query: Query) -> AdaptedFetchRequest<SQLRequest<GroupChatInfo>> {
    var sqlJoins: [String] = ["INNER JOIN groups g ON g.id = m.groupId"]
    var sqlWhere: [String] = []
    var sqlArguments: StatementArguments = [:]

    if let authStatus = query.authStatus {
      sqlWhere.append(sqlWhereAuthStatus(count: authStatus.count))
      _ = sqlArguments.append(contentsOf: sqlArgumentsAuthStatus(authStatus))
    }

    if query.isLeaderBlocked != nil || query.isLeaderBanned != nil {
      sqlJoins.append("INNER JOIN contacts l ON g.leaderId = l.id")

      if let isLeaderBlocked = query.isLeaderBlocked {
        sqlWhere.append("l.isBlocked = :isLeaderBlocked")
        _ = sqlArguments.append(contentsOf: StatementArguments([
          "isLeaderBlocked": isLeaderBlocked
        ]))
      }

      if let isLeaderBanned = query.isLeaderBanned {
        sqlWhere.append("l.isBanned = :isLeaderBanned")
        _ = sqlArguments.append(contentsOf: StatementArguments([
          "isLeaderBanned": isLeaderBanned
        ]))
      }
    }

    if query.excludeBlockedContactsMessages || query.excludeBannedContactsMessages {
      sqlJoins.append("INNER JOIN contacts s ON m.senderId = s.id")

      if query.excludeBlockedContactsMessages {
        sqlWhere.append("s.isBlocked != 1")
      }

      if query.excludeBannedContactsMessages {
        sqlWhere.append("s.isBanned != 1")
      }
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
      \(sqlJoins.joined(separator: "\n"))
      \(sqlWhere.isEmpty ? "" : "WHERE\n  \(sqlWhere.joined(separator: "\n  AND "))")
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
