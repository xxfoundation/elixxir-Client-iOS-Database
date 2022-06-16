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

      let contactChatsQuery = ContactChatInfo.Query(userId: query.userId)
      let contactChats = try fetchContactChats(contactChatsQuery)
        .map(ChatInfo.contactChat)

      let groupChatsQuery = GroupChatInfo.Query()
      let groupChats = try fetchGroupChats(groupChatsQuery)
        .map(ChatInfo.groupChat)

      let groupsQuery = Group.Query(
        withMessages: false,
        sortBy: .createdAt(desc: true)
      )
      let groups = try fetchGroups(groupsQuery)
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

      let contactChatsQuery = ContactChatInfo.Query(userId: query.userId)
      let groupChatsQuery = GroupChatInfo.Query()
      let groupsQuery = Group.Query(withMessages: false, sortBy: .createdAt(desc: true))

      return Publishers
        .CombineLatest3(
          fetchContactChats(contactChatsQuery).map { $0.map(ChatInfo.contactChat) },
          fetchGroupChats(groupChatsQuery).map { $0.map(ChatInfo.groupChat) },
          fetchGroups(groupsQuery).map { $0.map(ChatInfo.group) }
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
