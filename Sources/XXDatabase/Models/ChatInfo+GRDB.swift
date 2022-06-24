import Combine
import Foundation
import GRDB
import XXModels

extension Fetch where Model == ChatInfo, Query == ChatInfo.Query {
  static func grdb(
    _ writer: DatabaseWriter,
    _ queue: DispatchQueue
  ) -> Fetch<ChatInfo, ChatInfo.Query> {
    Fetch<ChatInfo, ChatInfo.Query> { query in
      let fetchContactChats: ContactChatInfo.Fetch =
        .grdb(writer, queue, ContactChatInfo.request(_:))

      let fetchGroupChats: GroupChatInfo.Fetch =
        .grdb(writer, queue, GroupChatInfo.request(_:))

      let fetchGroups: Group.Fetch =
        .grdb(writer, queue, Group.request(_:))

      let contactChats = try fetchContactChats(query.contactChatInfoQuery)
        .map(ChatInfo.contactChat)

      let groupChats = try fetchGroupChats(query.groupChatInfoQuery)
        .map(ChatInfo.groupChat)

      let groups = try fetchGroups(query.groupQuery)
        .map(ChatInfo.group)

      let chats = (contactChats + groupChats + groups)
        .sorted(by: { $0.date > $1.date })

      return chats
    }
  }
}

extension FetchPublisher where Model == ChatInfo, Query == ChatInfo.Query {
  static func grdb(
    _ writer: DatabaseWriter,
    _ queue: DispatchQueue
  ) -> FetchPublisher<ChatInfo, ChatInfo.Query> {
    FetchPublisher<ChatInfo, ChatInfo.Query> { query in
      let fetchContactChats: ContactChatInfo.FetchPublisher =
        .grdb(writer, queue, ContactChatInfo.request(_:))

      let fetchGroupChats: GroupChatInfo.FetchPublisher =
        .grdb(writer, queue, GroupChatInfo.request(_:))

      let fetchGroups: Group.FetchPublisher =
        .grdb(writer, queue, Group.request(_:))

      return Publishers
        .CombineLatest3(
          fetchContactChats(query.contactChatInfoQuery).map { $0.map(ChatInfo.contactChat) },
          fetchGroupChats(query.groupChatInfoQuery).map { $0.map(ChatInfo.groupChat) },
          fetchGroups(query.groupQuery).map { $0.map(ChatInfo.group) }
        )
        .map { (contactChats: [ChatInfo],
                groupChats: [ChatInfo],
                groups: [ChatInfo]) -> [ChatInfo] in
          contactChats + groupChats + groups
        }
        .map { (infos: [ChatInfo]) -> [ChatInfo] in
          infos.sorted(by: { $0.date > $1.date })
        }
        .eraseToAnyPublisher()
    }
  }
}
