import XCTest
import CustomDump
@testable import XXDatabase

final class DraftTests: XCTestCase {
  var db: XXDatabase.Database!

  override func setUp() async throws {
    db = try XXDatabase.Database.inMemory()
  }

  override func tearDown() async throws {
    db = nil
  }

  func testDatabase() throws {
    let contactA = Contact.stub("A")
    let contactB = Contact.stub("B")
    let contactC = Contact.stub("C")

    _ = try db.insert(contactA)
    _ = try db.insert(contactB)
    _ = try db.insert(contactC)

    XCTAssertEqual(
      try db.fetch(Contact.self, Contact.request(
        query: .init(),
        order: .username()
      )),
      [
        contactA,
        contactB,
        contactC,
      ]
    )

    let groupA = Group.stub(id: "A", leaderId: contactB.id)

    _ = try db.insert(groupA)
    _ = try db.insert(GroupMember(groupId: groupA.id, contactId: contactA.id))

    XCTAssertNoDifference(
      try db.fetch(GroupInfo.self, GroupInfo.request(
        query: .init(),
        order: .name()
      )),
      [
        GroupInfo(
          group: groupA,
          leader: contactB,
          members: [
            contactA,
          ]
        )
      ]
    )
  }
}

private extension Contact {
  static func stub(_ id: String) -> Contact {
    Contact(
      id: id.data(using: .utf8)!,
      marshaled: "stub_marshaled_\(id)".data(using: .utf8)!,
      username: "stub_username_\(id)",
      email: "stub_\(id)@elixxir.io",
      phone: "stub_phone_\(id)",
      nickname: "stub_nickname_\(id)"
    )
  }
}

private extension Group {
  static func stub(id: String, leaderId: Data) -> Group {
    Group(
      id: id.data(using: .utf8)!,
      name: "\(id)-name",
      leaderId: leaderId,
      createdAt: Date(timeIntervalSince1970: Date().timeIntervalSince1970.rounded())
    )
  }
}
