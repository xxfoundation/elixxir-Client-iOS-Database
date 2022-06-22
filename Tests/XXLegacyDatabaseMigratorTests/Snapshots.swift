import Foundation
import GRDB
import SnapshotTesting
import XXModels
@testable import XXDatabase

func assertSnapshot(
  matchingContactsIn reader: DatabaseReader,
  record recording: Bool = false,
  timeout: TimeInterval = 5,
  file: StaticString = #file,
  testName: String = #function,
  line: UInt = #line
) {
  assertSnapshot(
    matching: try reader.read(
      XXModels.Contact
        .order(XXModels.Contact.Column.createdAt)
        .fetchAll(_:)
    ),
    as: .json(snapshotJsonEncoder),
    named: "contacts",
    record: recording,
    timeout: timeout,
    file: file,
    testName: testName,
    line: line
  )
}

func assertSnapshot(
  matchingGroupsIn reader: DatabaseReader,
  record recording: Bool = false,
  timeout: TimeInterval = 5,
  file: StaticString = #file,
  testName: String = #function,
  line: UInt = #line
) {
  assertSnapshot(
    matching: try reader.read(
      XXModels.Group
        .order(XXModels.Group.Column.createdAt)
        .fetchAll(_:)
    ),
    as: .json(snapshotJsonEncoder),
    named: "groups",
    record: recording,
    timeout: timeout,
    file: file,
    testName: testName,
    line: line
  )
}

func assertSnapshot(
  matchingGroupMembersIn reader: DatabaseReader,
  record recording: Bool = false,
  timeout: TimeInterval = 5,
  file: StaticString = #file,
  testName: String = #function,
  line: UInt = #line
) {
  assertSnapshot(
    matching: try reader.read(
      XXModels.GroupMember
        .order(XXModels.GroupMember.Column.groupId)
        .fetchAll(_:)
    ),
    as: .json(snapshotJsonEncoder),
    named: "groupMembers",
    record: recording,
    timeout: timeout,
    file: file,
    testName: testName,
    line: line
  )
}

func assertSnapshot(
  matchingMessagesIn reader: DatabaseReader,
  record recording: Bool = false,
  timeout: TimeInterval = 5,
  file: StaticString = #file,
  testName: String = #function,
  line: UInt = #line
) {
  assertSnapshot(
    matching: try reader.read(
      XXModels.Message
        .order(XXModels.Message.Column.date)
        .fetchAll(_:)
    ),
    as: .json(snapshotJsonEncoder),
    named: "messages",
    record: recording,
    timeout: timeout,
    file: file,
    testName: testName,
    line: line
  )
}


func assertSnapshot(
  matchingFileTransfersIn reader: DatabaseReader,
  record recording: Bool = false,
  timeout: TimeInterval = 5,
  file: StaticString = #file,
  testName: String = #function,
  line: UInt = #line
) {
  assertSnapshot(
    matching: try reader.read(
      XXModels.FileTransfer
        .order(XXModels.FileTransfer.Column.createdAt)
        .fetchAll(_:)
    ),
    as: .json(snapshotJsonEncoder),
    named: "fileTransfers",
    record: recording,
    timeout: timeout,
    file: file,
    testName: testName,
    line: line
  )
}

private let snapshotJsonEncoder: JSONEncoder = {
  let encoder = JSONEncoder()
  encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
  encoder.dateEncodingStrategy = .iso8601
  encoder.dataEncodingStrategy = .base64
  return encoder
}()
