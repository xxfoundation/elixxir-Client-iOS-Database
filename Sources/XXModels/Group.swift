import Combine
import Foundation

public struct Group: Identifiable, Equatable, Codable {
  public init(
    id: Data,
    name: String,
    leaderId: Data,
    createdAt: Date
  ) {
    self.id = id
    self.name = name
    self.leaderId = leaderId
    self.createdAt = createdAt
  }

  public var id: Data
  public var name: String
  public var leaderId: Data
  public var createdAt: Date
}

extension Group {
  public typealias Save = (Group) throws -> Group
  public typealias SavePublisher = (Group) -> AnyPublisher<Group, Error>
  public typealias Delete = (Group) throws -> Bool
  public typealias DeletePublisher = (Group) -> AnyPublisher<Bool, Error>
}
