import Foundation
import GRDB

struct Group: Equatable, Codable {
  enum Status: Int64, Codable {
    case hidden
    case pending
    case deleting
    case participating
  }

  var id: Int64?
  var name: String
  var leader: Data
  var groupId: Data
  var status: Status
  var serialize: Data
  var createdAt: Date
}

extension Group: FetchableRecord, MutablePersistableRecord {
  enum Column: String, ColumnExpression {
    case id, name, leader, groupId, status, serialize, createdAt, accepted
  }

  static let databaseTableName = "groups"

  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
