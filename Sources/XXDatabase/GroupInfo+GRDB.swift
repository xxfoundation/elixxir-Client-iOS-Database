import GRDB
import XXModels

extension GroupInfo: FetchableRecord {
  public static func request(_ query: Query, _ order: Order) -> QueryInterfaceRequest<GroupMember> {
    var request = Group
      .including(required: Group.leader)
      .including(all: Group.members)
      .asRequest(of: GroupMember.self)

    // TODO: handle query

    switch order {
    case .groupName(desc: false):
      request = request.order(Group.Columns.name)

    case .groupName(desc: true):
      request = request.order(Group.Columns.name.desc)
    }

    return request
  }
}
