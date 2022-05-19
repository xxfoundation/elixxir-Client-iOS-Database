import GRDB
import XXModels

extension GroupInfo: FetchableRecord {
  public static func request(_ query: Query, _ order: Order) -> QueryInterfaceRequest<GroupMember> {
    var request = Group
      .including(required: Group.Association.leader)
      .including(all: Group.Association.members)
      .asRequest(of: GroupMember.self)

    // TODO: handle query

    switch order {
    case .groupName(desc: false):
      request = request.order(Group.Column.name)

    case .groupName(desc: true):
      request = request.order(Group.Column.name.desc)
    }

    return request
  }
}
