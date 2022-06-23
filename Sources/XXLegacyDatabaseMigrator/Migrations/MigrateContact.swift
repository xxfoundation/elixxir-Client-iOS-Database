import GRDB
import XXModels

public struct MigrateContact {
  var run: (Contact, XXModels.Database) throws -> Void

  func callAsFunction(
    _ contact: Contact,
    to newDb: XXModels.Database
  ) throws {
    try run(contact, newDb)
  }
}

extension MigrateContact {
  public static let live = MigrateContact { contact, newDb in
    try newDb.saveContact(.init(
      id: contact.userId,
      marshaled: contact.marshaled,
      username: contact.username,
      email: contact.email,
      phone: contact.phone,
      nickname: contact.nickname,
      photo: contact.photo,
      authStatus: authStatus(for: contact.status),
      isRecent: contact.isRecent,
      createdAt: contact.createdAt
    ))
  }

  static func authStatus(for status: Contact.Status) -> XXModels.Contact.AuthStatus {
    switch status {
    case .friend: return .friend
    case .stranger: return .stranger
    case .verified: return .verified
    case .verificationFailed: return .verificationFailed
    case .verificationInProgress: return .verificationInProgress
    case .requested: return .requested
    case .requesting: return .requesting
    case .requestFailed: return .requestFailed
    case .confirming: return .confirming
    case .confirmationFailed: return .confirmationFailed
    case .hidden: return .hidden
    }
  }
}
