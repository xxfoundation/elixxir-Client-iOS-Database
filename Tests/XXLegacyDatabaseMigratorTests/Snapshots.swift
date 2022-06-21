import GRDB
import XXModels
@testable import XXDatabase

struct DatabaseSnapshot: Equatable, Codable {
  var contacts: [XXModels.Contact]
  var groups: [XXModels.Group]
  var groupMembers: [XXModels.GroupMember]
  var fileTransfers: [XXModels.FileTransfer]
  var messages: [XXModels.Message]
}

extension DatabaseSnapshot {
  static func make(with reader: DatabaseReader) throws -> DatabaseSnapshot {
    DatabaseSnapshot(
      contacts: try reader.read(XXModels.Contact
        .order(XXModels.Contact.Column.createdAt)
        .fetchAll(_:)),
      groups: try reader.read(XXModels.Group
        .order(XXModels.Group.Column.createdAt)
        .fetchAll(_:)),
      groupMembers: try reader.read(XXModels.GroupMember
        .order(XXModels.GroupMember.Column.groupId)
        .fetchAll(_:)),
      fileTransfers: try reader.read(XXModels.FileTransfer
        .order(XXModels.FileTransfer.Column.createdAt)
        .fetchAll(_:)),
      messages: try reader.read(XXModels.Message
        .order(XXModels.Message.Column.date)
        .fetchAll(_:))
    )
  }
}
