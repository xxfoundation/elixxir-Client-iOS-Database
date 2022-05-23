import Combine
import GRDB
import XXModels

extension Database {
  public func fetch(_ query: ChatInfo.Query) throws -> [ChatInfo] {
    let fetchContactChats: ContactChatInfo.Fetch = fetch(ContactChatInfo.request(_:))
    let fetchGroupChats: GroupChatInfo.Fetch = fetch(GroupChatInfo.request(_:))

    let contactChatsQuery = ContactChatInfo.Query(userId: query.userId)
    let contactChats = try fetchContactChats(contactChatsQuery)
      .map(ChatInfo.contactChat)

    let groupChatsQuery = GroupChatInfo.Query()
    let groupChats = try fetchGroupChats(groupChatsQuery)
      .map(ChatInfo.groupChat)

    let chats = (contactChats + groupChats)
      .sorted(by: { $0.date > $1.date })

    return chats
  }

  public func fetchPublisher(_ query: ChatInfo.Query) -> AnyPublisher<[ChatInfo], Error> {
    let fetchContactChats: ContactChatInfo.FetchPublisher
    = fetchPublisher(ContactChatInfo.request(_:))

    let fetchGroupChats: GroupChatInfo.FetchPublisher
    = fetchPublisher(GroupChatInfo.request(_:))

    let contactChatsQuery = ContactChatInfo.Query(userId: query.userId)
    let groupChatsQuery = GroupChatInfo.Query()

    return Publishers
      .CombineLatest(
        fetchContactChats(contactChatsQuery).map { $0.map(ChatInfo.contactChat) },
        fetchGroupChats(groupChatsQuery).map { $0.map(ChatInfo.groupChat) }
      )
      .map { $0 + $1 }
      .map { $0.sorted(by: { $0.date > $1.date }) }
      .eraseToAnyPublisher()
  }
}
