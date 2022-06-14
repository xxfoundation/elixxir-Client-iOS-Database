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
    let fetch: Contact.Fetch = db.fetchContacts
    let insert: Contact.Insert = db.insertContact
    let update: Contact.Update = db.updateContact
    let save: Contact.Save = db.saveContact
    let delete: Contact.Delete = db.deleteContact

    // Insert contact A:

    let contactA = Contact.stub("A")
    XCTAssertNoDifference(try insert(contactA), contactA)

    // Insert contact B:

    let contactB = Contact.stub("B")
    XCTAssertNoDifference(try insert(contactB), contactB)

    // Insert contact C:

    let contactC = Contact.stub("C")
    XCTAssertNoDifference(try insert(contactC), contactC)

    // Fetch contacts:

    XCTAssertNoDifference(
      try fetch(Contact.Query(sortBy: .username())),
      [contactA, contactB, contactC]
    )

    // Update contact B:

    var updatedContactB = contactB
    updatedContactB.username!.append("-updated")
    XCTAssertNoDifference(try update(updatedContactB), updatedContactB)

    // Fetch contacts:

    XCTAssertNoDifference(
      try fetch(Contact.Query(sortBy: .username(desc: true))),
      [contactC, updatedContactB, contactA]
    )

    // Delete contact C:

    XCTAssertNoDifference(try delete(contactC), true)

    // Fetch contacts:

    XCTAssertNoDifference(
      try fetch(Contact.Query(sortBy: .username())),
      [contactA, updatedContactB]
    )

    // Save updated contact A:

    var updatedContactA = contactA
    updatedContactA.username!.append("-updated")
    XCTAssertNoDifference(try update(updatedContactA), updatedContactA)

    // Fetch contacts:

    XCTAssertNoDifference(
      try fetch(Contact.Query(sortBy: .username())),
      [updatedContactA, updatedContactB]
    )

    // Save new contact D:

    let contactD = Contact.stub("D")
    XCTAssertNoDifference(try save(contactD), contactD)

    // Fetch contacts:

    XCTAssertNoDifference(
      try fetch(Contact.Query(sortBy: .username())),
      [updatedContactA, updatedContactB, contactD]
    )
  }

  func testFetchPublisher() throws {
    let fetch: Contact.FetchPublisher = db.fetchContactsPublisher
    let fetchAssertion = PublisherAssertion<[Contact], Error>()

    // Subscribe to fetch publisher:

    fetchAssertion.expectValue()
    fetchAssertion.subscribe(to: fetch(Contact.Query(sortBy: .username())))
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(fetchAssertion.receivedValues(), [[]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Insert contact A:

    let contactA = try db.insertContact(.stub("A"))
    fetchAssertion.expectValue()
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(fetchAssertion.receivedValues(), [[contactA]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Insert contact B:

    let contactB = try db.insertContact(.stub("B"))
    fetchAssertion.expectValue()
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(fetchAssertion.receivedValues(), [[contactA, contactB]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Insert contact C:

    let contactC = try db.insertContact(.stub("C"))
    fetchAssertion.expectValue()
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(fetchAssertion.receivedValues(), [[contactA, contactB, contactC]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Update contact B:

    var updatedContactB = contactB
    updatedContactB.username!.append("-updated")
    fetchAssertion.expectValue()
    try db.updateContact(updatedContactB)
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
    let fetch: Contact.Fetch = db.fetchContacts

    // Mock up contacts:

    let contactA = try db.saveContact(.stub("A", authStatus: .stranger))
    let contactB = try db.saveContact(.stub("B", authStatus: .requested))
    let contactC = try db.saveContact(.stub("C", authStatus: .friend))
    let contactD = try db.saveContact(.stub("D", authStatus: .stranger))
    let contactE = try db.saveContact(.stub("E", authStatus: .requested))
    let contactF = try db.saveContact(.stub("F", authStatus: .friend))

    // Fetch contacts with auth status `stranger`:

    XCTAssertNoDifference(try fetch(Contact.Query(
      authStatus: [.stranger],
      sortBy: .username()
    )), [
      contactA,
      contactD,
    ])

    // Fetch contacts with auth status `requested`:

    XCTAssertNoDifference(try fetch(Contact.Query(
      authStatus: [.requested],
      sortBy: .username()
    )), [
      contactB,
      contactE,
    ])

    // Fetch contacts with auth status `friend`:

    XCTAssertNoDifference(try fetch(Contact.Query(
      authStatus: [.friend],
      sortBy: .username()
    )), [
      contactC,
      contactF,
    ])

    // Fetch contacts with auth status `requested` OR `friend`:

    XCTAssertNoDifference(try fetch(Contact.Query(
      authStatus: [.requested, .friend],
      sortBy: .username()
    )), [
      contactB,
      contactC,
      contactE,
      contactF,
    ])

    // Fetch all contacts, regardless auth status:

    XCTAssertNoDifference(try fetch(Contact.Query(
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
