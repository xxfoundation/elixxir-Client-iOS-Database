import Foundation
import GRDB

struct Contact: Equatable, Codable {
  enum Status: Int64, Codable {
    case friend
    case stranger
    case verified
    case verificationFailed
    case verificationInProgress
    case requested
    case requesting
    case requestFailed
    case confirming
    case confirmationFailed
    case hidden
  }

  var id: Int64?
  var photo: Data?
  var userId: Data
  var email: String?
  var phone: String?
  var status: Status
  var marshaled: Data
  var createdAt: Date
  var username: String
  var nickname: String?
  var isRecent: Bool
}

extension Contact: FetchableRecord, MutablePersistableRecord {
  enum Column: String, ColumnExpression {
    case id, photo, email, phone, userId, status, username,
         isRecent, nickname, marshaled, createdAt
  }

  static let databaseTableName = "contacts"

  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
