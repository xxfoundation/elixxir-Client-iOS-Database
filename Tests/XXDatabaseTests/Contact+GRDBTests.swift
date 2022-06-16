import Combine
import CustomDump
import XCTest
import XXModels
@testable import XXDatabase

final class ContactGRDBTests: XCTestCase {
  var db: Database!

  override func setUp() async throws {
    db = try Database.inMemory()
  }

  override func tearDown() async throws {
    db = nil
  }

  func testDatabaseOperations() throws {
    // Save new contact A:

    let contactA = Contact.stub("A", createdAt: .stub(2))
    XCTAssertNoDifference(try db.saveContact(contactA), contactA)

    // Save new contact B:

    let contactB = Contact.stub("B", createdAt: .stub(3))
    XCTAssertNoDifference(try db.saveContact(contactB), contactB)

    // Save new contact C:

    let contactC = Contact.stub("C", createdAt: .stub(1))
    XCTAssertNoDifference(try db.saveContact(contactC), contactC)

    // Fetch contacts:

    XCTAssertNoDifference(
      try db.fetchContacts(Contact.Query()),
      [contactA, contactB, contactC]
    )

    XCTAssertNoDifference(
      try db.fetchContacts(Contact.Query(sortBy: .username(desc: true))),
      [contactC, contactB, contactA]
    )

    XCTAssertNoDifference(
      try db.fetchContacts(Contact.Query(sortBy: .createdAt())),
      [contactC, contactA, contactB]
    )

    XCTAssertNoDifference(
      try db.fetchContacts(Contact.Query(sortBy: .createdAt(desc: true))),
      [contactB, contactA, contactC]
    )

    XCTAssertNoDifference(
      try db.fetchContacts(Contact.Query(id: [contactB.id])),
      [contactB]
    )

    XCTAssertNoDifference(
      try db.fetchContacts(Contact.Query(id: [contactC.id, contactA.id])),
      [contactA, contactC]
    )

    // Save updated contact B:

    var updatedContactB = contactB
    updatedContactB.username!.append("-updated")
    XCTAssertNoDifference(try db.saveContact(updatedContactB), updatedContactB)

    // Fetch contacts:

    XCTAssertNoDifference(
      try db.fetchContacts(Contact.Query()),
      [contactA, updatedContactB, contactC]
    )

    // Delete contact C:

    XCTAssertNoDifference(try db.deleteContact(contactC), true)

    // Fetch contacts:

    XCTAssertNoDifference(
      try db.fetchContacts(Contact.Query()),
      [contactA, updatedContactB]
    )

    // Save updated contact A:

    var updatedContactA = contactA
    updatedContactA.username!.append("-updated")
    XCTAssertNoDifference(try db.saveContact(updatedContactA), updatedContactA)

    // Fetch contacts:

    XCTAssertNoDifference(
      try db.fetchContacts(Contact.Query()),
      [updatedContactA, updatedContactB]
    )

    // Save new contact D:

    let contactD = Contact.stub("D")
    XCTAssertNoDifference(try db.saveContact(contactD), contactD)

    // Fetch contacts:

    XCTAssertNoDifference(
      try db.fetchContacts(Contact.Query()),
      [updatedContactA, updatedContactB, contactD]
    )
  }

  func testFetchPublisher() throws {
    let fetchAssertion = PublisherAssertion<[Contact], Error>()

    // Subscribe to fetch publisher:

    fetchAssertion.expectValue()
    fetchAssertion.subscribe(to: db.fetchContactsPublisher(Contact.Query(sortBy: .username())))
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(fetchAssertion.receivedValues(), [[]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Save new contact A:

    let contactA = try db.saveContact(.stub("A"))
    fetchAssertion.expectValue()
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(fetchAssertion.receivedValues(), [[contactA]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Save new contact B:

    let contactB = try db.saveContact(.stub("B"))
    fetchAssertion.expectValue()
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(fetchAssertion.receivedValues(), [[contactA, contactB]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Save new contact C:

    let contactC = try db.saveContact(.stub("C"))
    fetchAssertion.expectValue()
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(fetchAssertion.receivedValues(), [[contactA, contactB, contactC]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Save updated contact B:

    var updatedContactB = contactB
    updatedContactB.username!.append("-updated")
    fetchAssertion.expectValue()
    try db.saveContact(updatedContactB)
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(fetchAssertion.receivedValues(), [[contactA, updatedContactB, contactC]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Delete contact C:

    fetchAssertion.expectValue()
    try db.deleteContact(contactC)
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(fetchAssertion.receivedValues(), [[contactA, updatedContactB]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Save updated contact A:

    var updatedContactA = contactA
    updatedContactA.username!.append("-updated")
    fetchAssertion.expectValue()
    try db.saveContact(updatedContactA)
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(fetchAssertion.receivedValues(), [[updatedContactA, updatedContactB]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Save new contact D:

    let contactD = Contact.stub("D")
    fetchAssertion.expectValue()
    try db.saveContact(contactD)
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(fetchAssertion.receivedValues(), [[updatedContactA, updatedContactB, contactD]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Check if fetch publisher completed:

    XCTAssertNil(fetchAssertion.receivedCompletion())
  }

  func testFetchingAuthRequest() throws {
    // Mock up contacts:

    let contactA = try db.saveContact(.stub("A", authStatus: .stranger))
    let contactB = try db.saveContact(.stub("B", authStatus: .requested))
    let contactC = try db.saveContact(.stub("C", authStatus: .friend))
    let contactD = try db.saveContact(.stub("D", authStatus: .stranger))
    let contactE = try db.saveContact(.stub("E", authStatus: .requested))
    let contactF = try db.saveContact(.stub("F", authStatus: .friend))

    // Fetch contacts with auth status `stranger`:

    XCTAssertNoDifference(try db.fetchContacts(Contact.Query(
      authStatus: [.stranger],
      sortBy: .username()
    )), [
      contactA,
      contactD,
    ])

    // Fetch contacts with auth status `requested`:

    XCTAssertNoDifference(try db.fetchContacts(Contact.Query(
      authStatus: [.requested],
      sortBy: .username()
    )), [
      contactB,
      contactE,
    ])

    // Fetch contacts with auth status `friend`:

    XCTAssertNoDifference(try db.fetchContacts(Contact.Query(
      authStatus: [.friend],
      sortBy: .username()
    )), [
      contactC,
      contactF,
    ])

    // Fetch contacts with auth status `requested` OR `friend`:

    XCTAssertNoDifference(try db.fetchContacts(Contact.Query(
      authStatus: [.requested, .friend],
      sortBy: .username()
    )), [
      contactB,
      contactC,
      contactE,
      contactF,
    ])

    // Fetch all contacts, regardless auth status:

    XCTAssertNoDifference(try db.fetchContacts(Contact.Query(
      authStatus: nil,
      sortBy: .username()
    )), [
      contactA,
      contactB,
      contactC,
      contactD,
      contactE,
      contactF,
    ])
  }
}
