import Foundation
import GRDB

struct Message: Equatable, Codable {
  enum Status: Int64, Codable {
    case read
    case sent
    case sending
    case sendingAttachment
    case receivingAttachment
    case received
    case failedToSend
    case timedOut
  }

  var id: Int64?
  var unread: Bool
  var sender: Data
  var roundURL: String?
  var report: Data?
  var status: Status
  var receiver: Data
  var timestamp: Int
  var uniqueId: Data?
  var payload: Payload
}

extension Message: FetchableRecord, MutablePersistableRecord {
  enum Column: String, ColumnExpression {
    case id, report, sender, unread, status, payload, roundURL,
         receiver, uniqueId, timestamp
  }

  static let databaseTableName = "messages"

  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
