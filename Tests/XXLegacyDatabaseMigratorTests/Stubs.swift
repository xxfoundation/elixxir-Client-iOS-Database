import Foundation
import XXModels
@testable import XXLegacyDatabaseMigrator

extension Date {
  static func stub(_ ti: TimeInterval) -> Date {
    Date(timeIntervalSince1970: ti)
  }
}

extension XXLegacyDatabaseMigrator.Contact {
  static func stub(
    _ stubId: Int,
    status: Status = .friend,
    isRecent: Bool = false
  ) -> XXLegacyDatabaseMigrator.Contact {
    XXLegacyDatabaseMigrator.Contact(
      id: nil,
      photo: "photo-\(stubId)".data(using: .utf8)!,
      userId: "user-id-\(stubId)".data(using: .utf8)!,
      email: "email-\(stubId)",
      phone: "phone-\(stubId)",
      status: status,
      marshaled: "marshaled-\(stubId)".data(using: .utf8)!,
      createdAt: .stub(TimeInterval(stubId)),
      username: "username-\(stubId)",
      nickname: "nickname-\(stubId)",
      isRecent: isRecent
    )
  }
}

extension XXModels.Contact {
  static func stub(
    _ stubId: Int,
    authStatus: AuthStatus = .friend,
    isRecent: Bool = false
  ) -> XXModels.Contact {
    XXModels.Contact(
      id: "user-id-\(stubId)".data(using: .utf8)!,
      marshaled: "marshaled-\(stubId)".data(using: .utf8)!,
      username: "username-\(stubId)",
      email: "email-\(stubId)",
      phone: "phone-\(stubId)",
      nickname: "nickname-\(stubId)",
      photo: "photo-\(stubId)".data(using: .utf8)!,
      authStatus: authStatus,
      isRecent: isRecent,
      createdAt: .stub(TimeInterval(stubId))
    )
  }
}
