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

      let contactChats: [ChatInfo]
      if let query = query.contactChatInfoQuery {
        contactChats = try fetchContactChats(query).map(ChatInfo.contactChat)
      } else {
        contactChats = []
      }

      let groupChats: [ChatInfo]
      if let query = query.groupChatInfoQuery {
        groupChats = try fetchGroupChats(query).map(ChatInfo.groupChat)
      } else {
        groupChats = []
      }

      let groups: [ChatInfo]
      if let query = query.groupQuery {
        groups = try fetchGroups(query).map(ChatInfo.group)
      } else {
        groups = []
      }

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
      let contactChats: AnyPublisher<[ChatInfo], Error>
      if let query = query.contactChatInfoQuery {
        contactChats = ContactChatInfo.FetchPublisher
          .grdb(writer, queue, ContactChatInfo.request(_:))
          .run(query)
          .map { $0.map(ChatInfo.contactChat) }
          .eraseToAnyPublisher()
      } else {
        contactChats = Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
      }

      let groupChats: AnyPublisher<[ChatInfo], Error>
      if let query = query.groupChatInfoQuery {
        groupChats = GroupChatInfo.FetchPublisher
          .grdb(writer, queue, GroupChatInfo.request(_:))
          .run(query)
          .map { $0.map(ChatInfo.groupChat) }
          .eraseToAnyPublisher()
      } else {
        groupChats = Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
      }

      let groups: AnyPublisher<[ChatInfo], Error>
      if let query = query.groupQuery {
        groups = Group.FetchPublisher
          .grdb(writer, queue, Group.request(_:))
          .run(query)
          .map { $0.map(ChatInfo.group) }
          .eraseToAnyPublisher()
      } else {
        groups = Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
      }

      return Publishers
        .CombineLatest3(contactChats, groupChats, groups)
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
