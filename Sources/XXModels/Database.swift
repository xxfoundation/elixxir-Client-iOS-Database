/// Database operations interface
public struct Database {
  public init(
    fetchChatInfos: ChatInfo.Fetch,
    fetchChatInfosPublisher: ChatInfo.FetchPublisher,
    fetchContacts: Contact.Fetch,
    fetchContactsPublisher: Contact.FetchPublisher,
    saveContact: Contact.Save,
    bulkUpdateContacts: Contact.BulkUpdate,
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
    bulkUpdateMessages: Message.BulkUpdate,
    deleteMessage: Message.Delete,
    deleteMessages: Message.DeleteMany,
    fetchFileTransfers: FileTransfer.Fetch,
    fetchFileTransfersPublisher: FileTransfer.FetchPublisher,
    saveFileTransfer: FileTransfer.Save,
    deleteFileTransfer: FileTransfer.Delete,
    drop: Drop
  ) {
    self.fetchChatInfos = fetchChatInfos
    self.fetchChatInfosPublisher = fetchChatInfosPublisher
    self.fetchContacts = fetchContacts
    self.fetchContactsPublisher = fetchContactsPublisher
    self.saveContact = saveContact
    self.bulkUpdateContacts = bulkUpdateContacts
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
    self.bulkUpdateMessages = bulkUpdateMessages
    self.deleteMessage = deleteMessage
    self.deleteMessages = deleteMessages
    self.fetchFileTransfers = fetchFileTransfers
    self.fetchFileTransfersPublisher = fetchFileTransfersPublisher
    self.saveFileTransfer = saveFileTransfer
    self.deleteFileTransfer = deleteFileTransfer
    self.drop = drop
  }

  // MARK: - ChatInfo

  /// Fetch chat infos
  public var fetchChatInfos: ChatInfo.Fetch

  /// Fetch chat infos publisher
  public var fetchChatInfosPublisher: ChatInfo.FetchPublisher

  // MARK: - Contact

  /// Fetch contacts
  public var fetchContacts: Contact.Fetch

  /// Fetch contacts publisher
  public var fetchContactsPublisher: Contact.FetchPublisher

  /// Save (insert new or update existing) contact
  public var saveContact: Contact.Save

  /// Bulk update contacts
  public var bulkUpdateContacts: Contact.BulkUpdate

  /// Delete contact
  public var deleteContact: Contact.Delete

  // MARK: - ContactChatInfo

  /// Fetch contact chat infos
  public var fetchContactChatInfos: ContactChatInfo.Fetch

  /// Fetch contact chat infos publisher
  public var fetchContactChatInfosPublisher: ContactChatInfo.FetchPublisher

  // MARK: - Group

  /// Fetch groups
  public var fetchGroups: Group.Fetch

  /// Fetch groups publisher
  public var fetchGroupsPublisher: Group.FetchPublisher

  /// Save (insert new or update existing) group
  public var saveGroup: Group.Save

  /// Delete group
  public var deleteGroup: Group.Delete

  // MARK: - GroupChatInfo

  /// Fetch group chat infos
  public var fetchGroupChatInfos: GroupChatInfo.Fetch

  /// Fetch group chat infos publisher
  public var fetchGroupChatInfosPublisher: GroupChatInfo.FetchPublisher

  // MARK: - GroupInfo

  /// Fetch group infos
  public var fetchGroupInfos: GroupInfo.Fetch

  /// Fetch group infos publisher
  public var fetchGroupInfosPublisher: GroupInfo.FetchPublisher

  // MARK: - GroupMember

  /// Save group-member relation
  public var saveGroupMember: GroupMember.Save

  /// Delete group-member relation
  public var deleteGroupMember: GroupMember.Delete

  // MARK: - Message

  /// Fetch messages
  public var fetchMessages: Message.Fetch

  /// Fetch messages publisher
  public var fetchMessagesPublisher: Message.FetchPublisher

  /// Save message
  public var saveMessage: Message.Save

  /// Bulk update messages
  public var bulkUpdateMessages: Message.BulkUpdate

  /// Delete message
  public var deleteMessage: Message.Delete

  /// Delete messages
  public var deleteMessages: Message.DeleteMany

  // MARK: - FileTransfers

  /// Fetch file transfers
  public var fetchFileTransfers: FileTransfer.Fetch

  /// Fetch file transfers publisher
  public var fetchFileTransfersPublisher: FileTransfer.FetchPublisher

  /// Save file transfer
  public var saveFileTransfer: FileTransfer.Save

  /// Delete file transfer
  public var deleteFileTransfer: FileTransfer.Delete

  // MARK: - Other

  /// Drop database
  public var drop: Drop
}

#if DEBUG
extension Database {
  static public let failing = Database(
    fetchChatInfos: .failing(),
    fetchChatInfosPublisher: .failing(),
    fetchContacts: .failing(),
    fetchContactsPublisher: .failing(),
    saveContact: .failing(),
    bulkUpdateContacts: .failing(),
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
    bulkUpdateMessages: .failing(),
    deleteMessage: .failing(),
    deleteMessages: .failing(),
    fetchFileTransfers: .failing(),
    fetchFileTransfersPublisher: .failing(),
    saveFileTransfer: .failing(),
    deleteFileTransfer: .failing(),
    drop: .failing
  )

  static public let unimplemented = Database(
    fetchChatInfos: .unimplemented(),
    fetchChatInfosPublisher: .unimplemented(),
    fetchContacts: .unimplemented(),
    fetchContactsPublisher: .unimplemented(),
    saveContact: .unimplemented(),
    bulkUpdateContacts: .unimplemented(),
    deleteContact: .unimplemented(),
    fetchContactChatInfos: .unimplemented(),
    fetchContactChatInfosPublisher: .unimplemented(),
    fetchGroups: .unimplemented(),
    fetchGroupsPublisher: .unimplemented(),
    saveGroup: .unimplemented(),
    deleteGroup: .unimplemented(),
    fetchGroupChatInfos: .unimplemented(),
    fetchGroupChatInfosPublisher: .unimplemented(),
    fetchGroupInfos: .unimplemented(),
    fetchGroupInfosPublisher: .unimplemented(),
    saveGroupMember: .unimplemented(),
    deleteGroupMember: .unimplemented(),
    fetchMessages: .unimplemented(),
    fetchMessagesPublisher: .unimplemented(),
    saveMessage: .unimplemented(),
    bulkUpdateMessages: .unimplemented(),
    deleteMessage: .unimplemented(),
    deleteMessages: .unimplemented(),
    fetchFileTransfers: .unimplemented(),
    fetchFileTransfersPublisher: .unimplemented(),
    saveFileTransfer: .unimplemented(),
    deleteFileTransfer: .unimplemented(),
    drop: .unimplemented
  )
}
#endif
