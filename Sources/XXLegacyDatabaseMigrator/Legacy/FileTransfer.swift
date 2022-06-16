import Foundation
import GRDB

struct FileTransfer: Equatable, Codable {
  var tid: Data
  var id: Int64?
  var contact: Data
  var fileName: String
  var fileType: String
  var isIncoming: Bool
}

extension FileTransfer: FetchableRecord, MutablePersistableRecord {
  enum Column: String, ColumnExpression {
    case id, tid, contact, fileName, fileType, isIncoming
  }

  static let databaseTableName = "transfers"

  mutating func didInsert(with rowID: Int64, for column: String?) {
    if column == Column.id.rawValue {
      id = rowID
    }
  }
}
