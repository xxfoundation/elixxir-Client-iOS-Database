import GRDB

public struct Migration {
  var id: String
  var migrate: (GRDB.Database) throws -> Void
}

extension Sequence where Element == Migration {
  public static var all: [Migration] {[
  ]}
}
