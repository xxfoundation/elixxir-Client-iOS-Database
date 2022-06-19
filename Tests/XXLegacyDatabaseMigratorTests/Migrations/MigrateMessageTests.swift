import CustomDump
import GRDB
import XCTest
import XXDatabase
import XXModels
@testable import XXLegacyDatabaseMigrator

final class MigrateMessageTests: XCTestCase {
  var migrate: MigrateMessage!
  var newDb: XXModels.Database!

  override func setUp() async throws {
    migrate = .live
    newDb = try .inMemory()
  }

  override func tearDown() async throws {
    migrate = nil
    newDb = nil
  }

  func testMigrating() throws {
    // TODO:
  }

  func testMigratingReplyToUnknownMessage() throws {
    var legacyMessage = XXLegacyDatabaseMigrator.Message.stub(1)
    legacyMessage.payload.reply = .init(
      messageId: "unknown-message-id".data(using: .utf8)!,
      senderId: "unknown-contact-id".data(using: .utf8)!
    )

    XCTAssertThrowsError(try migrate(legacyMessage, to: newDb)) { error in
      XCTAssertEqual(
        error as? MigrateMessage.ReplyMessageNotFound,
        MigrateMessage.ReplyMessageNotFound()
      )
    }
  }
}
