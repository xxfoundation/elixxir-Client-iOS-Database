import Combine
import GRDB
import XXModels

extension Database {
  public func fetch(_ query: ChatInfo.Query) throws -> [ChatInfo] {
    let fetchContactChats: ContactChatInfo.Fetch = fetch(ContactChatInfo.request(_:))
    let fetchGroupChats: GroupChatInfo.Fetch = fetch(GroupChatInfo.request(_:))
    let fetchGroups: Group.Fetch = fetch(Group.request(_:))

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

  public func fetchPublisher(_ query: ChatInfo.Query) -> AnyPublisher<[ChatInfo], Error> {
    let fetchContactChats: ContactChatInfo.FetchPublisher
    = fetchPublisher(ContactChatInfo.request(_:))

    let fetchGroupChats: GroupChatInfo.FetchPublisher
    = fetchPublisher(GroupChatInfo.request(_:))

    let fetchGroups: Group.FetchPublisher
    = fetchPublisher(Group.request(_:))

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
