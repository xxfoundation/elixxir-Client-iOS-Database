import Foundation
import GRDB

struct GroupMember: Equatable, Codable {
  enum Status: Int64, Codable {
    case usernameSet
    case pendingUsername
  }

  var id: Int64?
  var userId: Data
  var groupId: Data
  var status: Status
  var username: String
  var photo: Data?
}

extension GroupMember: FetchableRecord, MutablePersistableRecord {
  enum Column: String, ColumnExpression {
    case id, photo, status, userId, groupId, username
  }

  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
