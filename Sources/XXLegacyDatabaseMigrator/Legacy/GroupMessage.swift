import Foundation
import GRDB

struct GroupMessage: Equatable, Codable {
  enum Status: Int64, Codable {
    case sent
    case read
    case failed
    case sending
    case received
  }

  var id: Int64?
  var uniqueId: Data?
  var groupId: Data
  var sender: Data
  var roundId: Int64?
  var payload: Payload
  var status: Status
  var roundURL: String?
  var unread: Bool
  var timestamp: Int
}

extension GroupMessage: FetchableRecord, MutablePersistableRecord {
  enum Column: String, ColumnExpression {
    case id, sender, status, unread, payload, groupId, uniqueId,
         roundURL, timestamp, roundId
  }

  static let databaseTableName = "groupMessages"

  mutating func didInsert(with rowID: Int64, for column: String?) {
    if column == Column.id.rawValue {
      id = rowID
    }
  }
}
