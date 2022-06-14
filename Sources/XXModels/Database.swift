public struct Database {
  public init(
    fetchChatInfos: ChatInfo.Fetch,
    fetchChatInfosPublisher: ChatInfo.FetchPublisher,
    fetchContacts: Contact.Fetch,
    fetchContactsPublisher: Contact.FetchPublisher,
    saveContact: Contact.Save,
    deleteContact: Contact.Delete,
    fetchContactChatInfos: ContactChatInfo.Fetch,
    fetchContactChatInfosPublisher: ContactChatInfo.FetchPublisher,
    fetchGroups: Group.Fetch,
    fetchGroupsPublisher: Group.FetchPublisher,
    saveGroup: Group.Save,
    deleteGroup: Group.Delete,
    fetchGroupChatInfos: GroupChatInfo.Fetch,
    fetchGroupChatInfosPublisher: GroupChatInfo.FetchPublisher,
    fetchGroupInfos: GroupInfo.Fetch,
    fetchGroupInfosPublisher: GroupInfo.FetchPublisher,
    saveGroupMember: GroupMember.Save,
    deleteGroupMember: GroupMember.Delete,
    fetchMessages: Message.Fetch,
    fetchMessagesPublisher: Message.FetchPublisher,
    saveMessage: Message.Save,
    deleteMessage: Message.Delete
  ) {
    self.fetchChatInfos = fetchChatInfos
    self.fetchChatInfosPublisher = fetchChatInfosPublisher
    self.fetchContacts = fetchContacts
    self.fetchContactsPublisher = fetchContactsPublisher
    self.saveContact = saveContact
    self.deleteContact = deleteContact
    self.fetchContactChatInfos = fetchContactChatInfos
    self.fetchContactChatInfosPublisher = fetchContactChatInfosPublisher
    self.fetchGroups = fetchGroups
    self.fetchGroupsPublisher = fetchGroupsPublisher
    self.saveGroup = saveGroup
    self.deleteGroup = deleteGroup
    self.fetchGroupChatInfos = fetchGroupChatInfos
    self.fetchGroupChatInfosPublisher = fetchGroupChatInfosPublisher
    self.fetchGroupInfos = fetchGroupInfos
    self.fetchGroupInfosPublisher = fetchGroupInfosPublisher
    self.saveGroupMember = saveGroupMember
    self.deleteGroupMember = deleteGroupMember
    self.fetchMessages = fetchMessages
    self.fetchMessagesPublisher = fetchMessagesPublisher
    self.saveMessage = saveMessage
    self.deleteMessage = deleteMessage
  }

  // MARK: - ChatInfo

  public var fetchChatInfos: ChatInfo.Fetch
  public var fetchChatInfosPublisher: ChatInfo.FetchPublisher

  // MARK: - Contact

  public var fetchContacts: Contact.Fetch
  public var fetchContactsPublisher: Contact.FetchPublisher
  public var saveContact: Contact.Save
  public var deleteContact: Contact.Delete

  // MARK: - ContactChatInfo

  public var fetchContactChatInfos: ContactChatInfo.Fetch
  public var fetchContactChatInfosPublisher: ContactChatInfo.FetchPublisher

  // MARK: - Group

  public var fetchGroups: Group.Fetch
  public var fetchGroupsPublisher: Group.FetchPublisher
  public var saveGroup: Group.Save
  public var deleteGroup: Group.Delete

  // MARK: - GroupChatInfo

  public var fetchGroupChatInfos: GroupChatInfo.Fetch
  public var fetchGroupChatInfosPublisher: GroupChatInfo.FetchPublisher

  // MARK: - GroupInfo

  public var fetchGroupInfos: GroupInfo.Fetch
  public var fetchGroupInfosPublisher: GroupInfo.FetchPublisher

  // MARK: - GroupMember

  public var saveGroupMember: GroupMember.Save
  public var deleteGroupMember: GroupMember.Delete

  // MARK: - Message

  public var fetchMessages: Message.Fetch
  public var fetchMessagesPublisher: Message.FetchPublisher
  public var saveMessage: Message.Save
  public var deleteMessage: Message.Delete
}

extension Database {
  static public let failing = Database(
    fetchChatInfos: .failing(),
    fetchChatInfosPublisher: .failing(),
    fetchContacts: .failing(),
    fetchContactsPublisher: .failing(),
    saveContact: .failing(),
    deleteContact: .failing(),
    fetchContactChatInfos: .failing(),
    fetchContactChatInfosPublisher: .failing(),
    fetchGroups: .failing(),
    fetchGroupsPublisher: .failing(),
    saveGroup: .failing(),
    deleteGroup: .failing(),
    fetchGroupChatInfos: .failing(),
    fetchGroupChatInfosPublisher: .failing(),
    fetchGroupInfos: .failing(),
    fetchGroupInfosPublisher: .failing(),
    saveGroupMember: .failing(),
    deleteGroupMember: .failing(),
    fetchMessages: .failing(),
    fetchMessagesPublisher: .failing(),
    saveMessage: .failing(),
    deleteMessage: .failing()
  )
}
