import Combine
import GRDB
import XXModels

extension Database {
  public func fetch(_ query: ChatInfo.Query) throws -> [ChatInfo] {
    let fetchContactChats: ContactChatInfo.Fetch = fetch(ContactChatInfo.request(_:))
    let fetchGroupChats: GroupChatInfo.Fetch = fetch(GroupChatInfo.request(_:))

    let contactChatsQuery = ContactChatInfo.Query(userId: query.userId)
    let contactChats = try fetchContactChats(contactChatsQuery)
      .map(ChatInfo.contact)

    let groupChatsQuery = GroupChatInfo.Query()
    let groupChats = try fetchGroupChats(groupChatsQuery)
      .map(ChatInfo.group)

    let chats = (contactChats + groupChats)
      .sorted(by: { $0.lastMessage.date > $1.lastMessage.date })

    return chats
  }

  public func fetchPublisher(_ query: ChatInfo.Query) -> AnyPublisher<[ChatInfo], Error> {
    let contacts: ContactChatInfo.FetchPublisher = fetchPublisher(ContactChatInfo.request(_:))
    let groups: GroupChatInfo.FetchPublisher = fetchPublisher(GroupChatInfo.request(_:))

    let contactChatsQuery = ContactChatInfo.Query(userId: query.userId)
    let groupChatsQuery = GroupChatInfo.Query()

    return Publishers
      .CombineLatest(
        contacts(contactChatsQuery).map { $0.map(ChatInfo.contact) },
        groups(groupChatsQuery).map { $0.map(ChatInfo.group) }
      )
      .map { $0 + $1 }
      .map { $0.sorted(by: { $0.lastMessage.date > $1.lastMessage.date }) }
      .eraseToAnyPublisher()
  }
}
