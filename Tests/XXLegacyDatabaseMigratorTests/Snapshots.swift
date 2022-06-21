import GRDB
import XXModels

struct DatabaseSnapshot: Equatable, Codable {

}

extension DatabaseSnapshot {
  static func make(with reader: DatabaseReader) throws -> DatabaseSnapshot {
    DatabaseSnapshot()
  }
}
