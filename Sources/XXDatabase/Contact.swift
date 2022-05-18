import Combine
import Foundation
import GRDB
import XXModels

struct ContactRecord: Codable, FetchableRecord, PersistableRecord {
  enum Columns {
    static let id = Column(CodingKeys.id)
    static let marshaled = Column(CodingKeys.marshaled)
    static let username = Column(CodingKeys.username)
    static let email = Column(CodingKeys.email)
    static let phone = Column(CodingKeys.phone)
    static let nickname = Column(CodingKeys.nickname)
  }

  static let databaseTableName: String = "contacts"

  var id: Data
  var marshaled: Data
  var username: String?
  var email: String?
  var phone: String?
  var nickname: String?
}

private func toModel(_ record: ContactRecord) -> Contact {
  Contact(
    id: record.id,
    marshaled: record.marshaled,
    username: record.username,
    email: record.email,
    phone: record.phone,
    nickname: record.nickname
  )
}

private func toRecord(_ model: Contact) -> ContactRecord {
  ContactRecord(
    id: model.id,
    marshaled: model.marshaled,
    username: model.username,
    email: model.email,
    phone: model.phone,
    nickname: model.nickname
  )
}

private func request(
  _ query: Contact.Query,
  _ order: Contact.Order
) -> QueryInterfaceRequest<ContactRecord> {
  var request = ContactRecord.all()
  switch order {
  case .username(let desc):
    let column = ContactRecord.Columns.username
    request = request.order(desc ? column.desc : column)
  }
  return request
}

extension Database {
  public func fetch() -> Contact.Fetch {
    fetch(request: request, toModel: toModel)
  }

  public func fetchPublisher() -> Contact.FetchPublisher {
    fetchPublisher(request: request, toModel: toModel)
  }

  public func insert() -> Contact.Insert {
    insert(toRecord: toRecord, toModel: toModel)
  }

  public func insertPublisher() -> Contact.InsertPublisher {
    insertPublisher(toRecord: toRecord, toModel: toModel)
  }

  public func update() -> Contact.Update {
    update(toRecord: toRecord, toModel: toModel)
  }

  public func updatePublisher() -> Contact.UpdatePublisher {
    updatePublisher(toRecord: toRecord, toModel: toModel)
  }

  public func delete() -> Contact.Delete {
    delete(toRecord: toRecord)
  }

  public func deletePublisher() -> Contact.DeletePublisher {
    deletePublisher(toRecord: toRecord)
  }
}
