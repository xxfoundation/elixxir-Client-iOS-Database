import Foundation
import GRDB

struct GroupInfo: Identifiable, Equatable, Decodable {
  var id: Group.ID { group.id }
  var group: Group
  var leader: Contact
  var members: [Contact]
}

extension GroupInfo: FetchableRecord {
  struct Query: Equatable {
    init() {}
  }

  enum Order: Equatable {
    case name(desc: Bool = false)
  }

  static func request(query: Query, order: Order) -> QueryInterfaceRequest<Group> {
    var request = Group
      .including(required: Group.leader)
      .including(all: Group.members)

    // TODO: handle query

    switch order {
    case .name(let desc):
      let column = Group.Columns.name
      request = request.order(desc ? column.desc : column)
    }

    return request
  }
}
