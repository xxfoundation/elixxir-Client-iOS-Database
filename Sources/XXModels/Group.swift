import Combine
import Foundation

public struct Group: Identifiable, Equatable, Codable {
  public typealias ID = Data

  public init(
    id: ID,
    name: String,
    leaderId: Contact.ID,
    createdAt: Date
  ) {
    self.id = id
    self.name = name
    self.leaderId = leaderId
    self.createdAt = createdAt
  }

  public var id: ID
  public var name: String
  public var leaderId: Contact.ID
  public var createdAt: Date
}

extension Group {
  public typealias Save = (Group) throws -> Group
  public typealias SavePublisher = (Group) -> AnyPublisher<Group, Error>
  public typealias Delete = (Group) throws -> Bool
  public typealias DeletePublisher = (Group) -> AnyPublisher<Bool, Error>
}
