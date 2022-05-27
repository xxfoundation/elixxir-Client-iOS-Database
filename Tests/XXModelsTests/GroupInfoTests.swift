import XCTest
@testable import XXModels

final class GroupInfoTests: XCTestCase {
  func testId() {
    let leader = Contact(
      id: "contact-id".data(using: .utf8)!
    )

    let group = Group(
      id: "group-id".data(using: .utf8)!,
      name: "",
      leaderId: leader.id,
      createdAt: Date(),
      authStatus: .pending
    )

    let groupInfo = GroupInfo(
      group: group,
      leader: leader,
      members: []
    )

    XCTAssertEqual(groupInfo.id, group.id)
  }
}
