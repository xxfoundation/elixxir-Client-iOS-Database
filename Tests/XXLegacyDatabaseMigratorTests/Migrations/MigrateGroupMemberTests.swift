import CustomDump
import GRDB
import XCTest
import XXDatabase
import XXModels
@testable import XXLegacyDatabaseMigrator

final class MigrateGroupMemberTests: XCTestCase {
  var migrate: MigrateGroupMember!
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
    let groupLeader = try newDb.saveContact(.stub(1))
    let groupMember1 = try newDb.saveContact(.stub(2))
    let groupMember2 = try newDb.saveContact(.stub(3))
    let groupMember3 = try newDb.saveContact(.stub(4))
    let group = try newDb.saveGroup(.stub(5, leaderId: groupLeader.id))
    try newDb.saveGroupMember(.init(groupId: group.id, contactId: groupLeader.id))
    try newDb.saveGroupMember(.init(groupId: group.id, contactId: groupMember1.id))
    try newDb.saveGroupMember(.init(groupId: group.id, contactId: groupMember2.id))

    let legacyGroupMember = XXLegacyDatabaseMigrator.GroupMember.stub(
      6,
      userId: groupMember3.id,
      groupId: group.id
    )

    try migrate(legacyGroupMember, to: newDb)

    XCTAssertNoDifference(
      try newDb.fetchGroupInfos(.init(groupId: group.id)).first?.members,
      [
        groupLeader,
        groupMember1,
        groupMember2,
        groupMember3,
      ]
    )
  }

  func testMigratingWhenGroupDoesNotExist() throws {
    let legacyGroupMember = XXLegacyDatabaseMigrator.GroupMember.stub(1)

    XCTAssertThrowsError(try migrate(legacyGroupMember, to: newDb)) { error in
      XCTAssertNoDifference(
        error as? MigrateGroupMember.GroupNotFound,
        MigrateGroupMember.GroupNotFound()
      )
    }

    XCTAssertNoDifference(try newDb.fetchGroupInfos(.init()), [])
    XCTAssertNoDifference(try newDb.fetchContacts(.init()), [])
  }

  func testMigratingWhenContactDoesNotExist() throws {
    let groupLeader = try newDb.saveContact(.stub(1))
    let groupMember1 = try newDb.saveContact(.stub(2))
    let groupMember2 = try newDb.saveContact(.stub(3))
    let group = try newDb.saveGroup(.stub(4, leaderId: groupLeader.id))
    try newDb.saveGroupMember(.init(groupId: group.id, contactId: groupLeader.id))
    try newDb.saveGroupMember(.init(groupId: group.id, contactId: groupMember1.id))
    try newDb.saveGroupMember(.init(groupId: group.id, contactId: groupMember2.id))

    let legacyGroupMember = XXLegacyDatabaseMigrator.GroupMember.stub(
      5,
      groupId: group.id
    )

    try migrate(legacyGroupMember, to: newDb)

    XCTAssertNoDifference(
      try newDb.fetchGroupInfos(.init(groupId: group.id)).first?.members,
      [
        groupLeader,
        groupMember1,
        groupMember2,
        XXModels.Contact(
          id: legacyGroupMember.userId,
          username: legacyGroupMember.username,
          photo: legacyGroupMember.photo,
          createdAt: group.createdAt
        ),
      ]
    )

    XCTAssertNoDifference(
      try newDb.fetchContacts(.init(id: [legacyGroupMember.userId])).first,
      XXModels.Contact(
        id: legacyGroupMember.userId,
        username: legacyGroupMember.username,
        photo: legacyGroupMember.photo,
        createdAt: group.createdAt
      )
    )
  }
}
