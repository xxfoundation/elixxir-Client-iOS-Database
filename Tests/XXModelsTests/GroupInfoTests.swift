import XCTest
@testable import XXModels

final class GroupInfoTests: XCTestCase {
  func testId() {
    let leader = Contact(
      id: "contact-id".data(using: .utf8)!,
      authorized: false
    )

    let group = Group(
      id: "group-id".data(using: .utf8)!,
      name: "",
      leaderId: leader.id,
      createdAt: Date()
    )

    let groupInfo = GroupInfo(
      group: group,
      leader: leader,
      members: []
    )

    XCTAssertEqual(groupInfo.id, group.id)
  }
}
