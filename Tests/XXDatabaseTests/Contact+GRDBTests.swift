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

  func testFetchingByUsername() throws {
    // Mock up contacts:

    let contactA = try db.saveContact(.stub("A", createdAt: .stub(1)))
    let contactB = try db.saveContact(.stub("B", createdAt: .stub(2)).withUsername(nil))
    let contactC = try db.saveContact(.stub("C", createdAt: .stub(3)))
    let contactD = try db.saveContact(.stub("D", createdAt: .stub(4)).withUsername(nil))

    // Fetch contacts with provided username:

    XCTAssertNoDifference(
      try db.fetchContacts(.init(username: contactA.username!)),
      [contactA]
    )

    XCTAssertNoDifference(
      try db.fetchContacts(.init(username: contactC.username!)),
      [contactC]
    )

    // Fetch contacts without username:

    XCTAssertNoDifference(
      try db.fetchContacts(.init(username: .some(nil), sortBy: .createdAt())),
      [contactB, contactD]
    )

    // Fetch contacts regardless username:

    XCTAssertNoDifference(
      try db.fetchContacts(.init(username: nil, sortBy: .createdAt())),
      [contactA, contactB, contactC, contactD]
    )
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

  func testFetchingRecent() throws {
    // Mock up contacts:

    let contactA = try db.saveContact(.stub("A", isRecent: true))
    let contactB = try db.saveContact(.stub("B", isRecent: false))
    let contactC = try db.saveContact(.stub("C", isRecent: true))
    let contactD = try db.saveContact(.stub("D", isRecent: false))
    let contactE = try db.saveContact(.stub("E", isRecent: true))
    let contactF = try db.saveContact(.stub("F", isRecent: false))

    // Fetch recent contacts:

    XCTAssertNoDifference(try db.fetchContacts(.init(isRecent: true)), [
      contactA,
      contactC,
      contactE,
    ])

    // Fetch non-recent contacts:

    XCTAssertNoDifference(try db.fetchContacts(.init(isRecent: false)), [
      contactB,
      contactD,
      contactF,
    ])

    // Fetch contacts regardless recent status:

    XCTAssertNoDifference(try db.fetchContacts(.init(isRecent: nil)), [
      contactA,
      contactB,
      contactC,
      contactD,
      contactE,
      contactF,
    ])
  }

  func testBulkUpdateAuthStatus() throws {
    // Mock up contacts:

    let contactA = try db.saveContact(.stub("A", authStatus: .stranger))
    let contactB = try db.saveContact(.stub("B", authStatus: .verificationFailed))
    let contactC = try db.saveContact(.stub("C", authStatus: .requested))
    let contactD = try db.saveContact(.stub("D", authStatus: .verificationInProgress))
    let contactE = try db.saveContact(.stub("E", authStatus: .confirming))
    let contactF = try db.saveContact(.stub("F", authStatus: .verificationInProgress))

    // Bulk update auth status:

    let updatedContactsCount = try db.bulkUpdateContacts(
      .init(authStatus: [.verificationInProgress]),
      .init(authStatus: .verificationFailed)
    )

    XCTAssertEqual(updatedContactsCount, 2)

    XCTAssertNoDifference(try db.fetchContacts(.init()), [
      contactA,
      contactB,
      contactC,
      contactD.withAuthStatus(.verificationFailed),
      contactE,
      contactF.withAuthStatus(.verificationFailed),
    ])
  }

  func testFetchingByText() throws {
    // Mock up contacts:

    let contactA = try db.saveContact(.stub("A")
      .withUsername("john_a")
      .withEmail("john.a@test.com")
      .withPhone("100-200-001")
      .withNickname("JohnA")
      .withCreatedAt(.stub(1))
    )
    let contactB = try db.saveContact(.stub("B")
      .withUsername("john_b")
      .withEmail("john.b@test.com")
      .withPhone("100-123-002")
      .withNickname("JohnB")
      .withCreatedAt(.stub(2))
    )
    let contactC = try db.saveContact(.stub("C")
      .withUsername("mary-1")
      .withEmail("mary2@test.com")
      .withPhone("100-123-003")
      .withNickname("Mary1")
      .withCreatedAt(.stub(3))
    )
    let contactD = try db.saveContact(.stub("D")
      .withUsername("mary-2")
      .withEmail("mary2@test.com")
      .withPhone("100-200-004")
      .withNickname("Mary2")
      .withCreatedAt(.stub(4))
    )
    let contactE = try db.saveContact(.stub("E")
      .withUsername("admin1")
      .withEmail("admin1@test.com")
      .withPhone("100-200-005")
      .withNickname("Admin 100% (1)")
      .withCreatedAt(.stub(5))
    )
    let contactF = try db.saveContact(.stub("F")
      .withUsername("admin2")
      .withEmail("admin2@test.com")
      .withPhone("100-123-006")
      .withNickname("Admin 100% (2)")
      .withCreatedAt(.stub(6))
    )

    // Fetch contacts with text:

    XCTAssertNoDifference(try db.fetchContacts(.init(text: "john", sortBy: .createdAt())), [
      contactA,
      contactB,
    ])

    XCTAssertNoDifference(try db.fetchContacts(.init(text: "John", sortBy: .createdAt())), [
      contactA,
      contactB,
    ])

    XCTAssertNoDifference(try db.fetchContacts(.init(text: "mary", sortBy: .createdAt())), [
      contactC,
      contactD,
    ])

    XCTAssertNoDifference(try db.fetchContacts(.init(text: "123", sortBy: .createdAt())), [
      contactB,
      contactC,
      contactF,
    ])

    XCTAssertNoDifference(try db.fetchContacts(.init(text: "100%", sortBy: .createdAt())), [
      contactE,
      contactF,
    ])

    // Fetch contacts with `nil` text query:

    XCTAssertNoDifference(try db.fetchContacts(.init(text: nil, sortBy: .createdAt())), [
      contactA,
      contactB,
      contactC,
      contactD,
      contactE,
      contactF,
    ])
  }

  func testFetchingByBlockedStatus() throws {
    // Mock up contacts:

    let contactA = try db.saveContact(.stub("A").withBlocked(false))
    let contactB = try db.saveContact(.stub("B").withBlocked(true))
    let contactC = try db.saveContact(.stub("C").withBlocked(false))
    let contactD = try db.saveContact(.stub("D").withBlocked(true))

    // Fetch blocked contacts:

    XCTAssertNoDifference(try db.fetchContacts(.init(isBlocked: true)), [
      contactB,
      contactD,
    ])

    // Fetch not blocked contacts:

    XCTAssertNoDifference(try db.fetchContacts(.init(isBlocked: false)), [
      contactA,
      contactC,
    ])

    // Fetch contacts regardless blocked status:

    XCTAssertNoDifference(try db.fetchContacts(.init(isBlocked: nil)), [
      contactA,
      contactB,
      contactC,
      contactD,
    ])
  }

  func testFetchingByBannedStatus() throws {
    // Mock up contacts:

    let contactA = try db.saveContact(.stub("A").withBanned(false))
    let contactB = try db.saveContact(.stub("B").withBanned(true))
    let contactC = try db.saveContact(.stub("C").withBanned(false))
    let contactD = try db.saveContact(.stub("D").withBanned(true))

    // Fetch banned contacts:

    XCTAssertNoDifference(try db.fetchContacts(.init(isBanned: true)), [
      contactB,
      contactD,
    ])

    // Fetch not banned contacts:

    XCTAssertNoDifference(try db.fetchContacts(.init(isBanned: false)), [
      contactA,
      contactC,
    ])

    // Fetch contacts regardless banned status:

    XCTAssertNoDifference(try db.fetchContacts(.init(isBanned: nil)), [
      contactA,
      contactB,
      contactC,
      contactD,
    ])
  }
}
