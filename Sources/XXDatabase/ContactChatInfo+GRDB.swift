import GRDB
import XXModels

extension ContactChatInfo: FetchableRecord {
  enum Column: String, ColumnExpression {
    case contact
    case lastMessage
  }

  public static func request(_ query: Query) -> QueryInterfaceRequest<ContactChatInfo> {
#warning("FIXME !!!")

    let lastMessageRequest = Message
      .annotated(with: max(Message.Column.date))
      .group(Message.Column.senderId || Message.Column.recipientId)

    let lastMessageExpression = CommonTableExpression<Message>(
      named: Column.lastMessage.rawValue,
      request: lastMessageRequest
    )

    let lastMessageAssociation = Contact
      .association(
        to: lastMessageExpression,
        on: { contactTable, messageTable in
          messageTable[Message.Column.senderId] == contactTable[Contact.Column.id] ||
          messageTable[Message.Column.recipientId] == contactTable[Contact.Column.id]
        }
      )
      .order(Message.Column.date.desc)

    let request = Contact
      .filter(Contact.Column.id != query.userId)
      .with(lastMessageExpression)
      .including(required: lastMessageAssociation)
      .order(sql: "\(lastMessageExpression.tableName).\(Message.Column.date.rawValue) DESC")
      .asRequest(of: ContactChatInfo.self)

    return request
  }
}
