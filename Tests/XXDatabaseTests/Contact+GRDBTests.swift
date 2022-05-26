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
    let fetch: Contact.Fetch = db.fetch(Contact.request(_:))
    let insert: Contact.Insert = db.insert()
    let update: Contact.Update = db.update()
    let save: Contact.Save = db.save()
    let delete: Contact.Delete = db.delete()

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

  func testDatabaseOperationPublishers() {
    let fetch: Contact.FetchPublisher = db.fetchPublisher(Contact.request(_:))
    let insert: Contact.InsertPublisher = db.insertPublisher()
    let update: Contact.UpdatePublisher = db.updatePublisher()
    let save: Contact.SavePublisher = db.savePublisher()
    let delete: Contact.DeletePublisher = db.deletePublisher()

    let fetchAssertion = PublisherAssertion<[Contact], Error>()
    let insertAssertion = PublisherAssertion<Contact, Error>()
    let updateAssertion = PublisherAssertion<Contact, Error>()
    let saveAssertion = PublisherAssertion<Contact, Error>()
    let deleteAssertion = PublisherAssertion<Bool, Error>()

    // Subscribe to fetch publisher:

    fetchAssertion.expectValue()
    fetchAssertion.subscribe(to: fetch(Contact.Query(sortBy: .username())))
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(fetchAssertion.receivedValues(), [[]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Insert contact A:

    let contactA = Contact.stub("A")
    insertAssertion.expectValue()
    insertAssertion.expectCompletion()
    fetchAssertion.expectValue()
    insertAssertion.subscribe(to: insert(contactA))
    insertAssertion.waitForValues()
    insertAssertion.waitForCompletion()
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(insertAssertion.receivedValues(), [contactA])
    XCTAssert(insertAssertion.receivedCompletion()?.isFinished == true)
    XCTAssertNoDifference(fetchAssertion.receivedValues(), [[contactA]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Insert contact B:

    let contactB = Contact.stub("B")
    insertAssertion.expectValue()
    insertAssertion.expectCompletion()
    fetchAssertion.expectValue()
    insertAssertion.subscribe(to: insert(contactB))
    insertAssertion.waitForValues()
    insertAssertion.waitForCompletion()
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(insertAssertion.receivedValues(), [contactB])
    XCTAssert(insertAssertion.receivedCompletion()?.isFinished == true)
    XCTAssertNoDifference(fetchAssertion.receivedValues(), [[contactA, contactB]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Insert contact C:

    let contactC = Contact.stub("C")
    insertAssertion.expectValue()
    insertAssertion.expectCompletion()
    fetchAssertion.expectValue()
    insertAssertion.subscribe(to: insert(contactC))
    insertAssertion.waitForValues()
    insertAssertion.waitForCompletion()
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(insertAssertion.receivedValues(), [contactC])
    XCTAssert(insertAssertion.receivedCompletion()?.isFinished == true)
    XCTAssertNoDifference(fetchAssertion.receivedValues(), [[contactA, contactB, contactC]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Update contact B:

    var updatedContactB = contactB
    updatedContactB.username!.append("-updated")
    updateAssertion.expectValue()
    updateAssertion.expectCompletion()
    fetchAssertion.expectValue()
    updateAssertion.subscribe(to: update(updatedContactB))
    updateAssertion.waitForValues()
    updateAssertion.waitForCompletion()
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(updateAssertion.receivedValues(), [updatedContactB])
    XCTAssert(updateAssertion.receivedCompletion()?.isFinished == true)
    XCTAssertNoDifference(fetchAssertion.receivedValues(), [[contactA, updatedContactB, contactC]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Delete contact C:

    deleteAssertion.expectValue()
    deleteAssertion.expectCompletion()
    fetchAssertion.expectValue()
    deleteAssertion.subscribe(to: delete(contactC))
    deleteAssertion.waitForValues()
    deleteAssertion.waitForCompletion()
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(deleteAssertion.receivedValues(), [true])
    XCTAssert(deleteAssertion.receivedCompletion()?.isFinished == true)
    XCTAssertNoDifference(fetchAssertion.receivedValues(), [[contactA, updatedContactB]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Save updated contact A:

    var updatedContactA = contactA
    updatedContactA.username!.append("-updated")
    saveAssertion.expectValue()
    saveAssertion.expectCompletion()
    fetchAssertion.expectValue()
    saveAssertion.subscribe(to: save(updatedContactA))
    saveAssertion.waitForValues()
    saveAssertion.waitForCompletion()
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(saveAssertion.receivedValues(), [updatedContactA])
    XCTAssert(saveAssertion.receivedCompletion()?.isFinished == true)
    XCTAssertNoDifference(fetchAssertion.receivedValues(), [[updatedContactA, updatedContactB]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Save new contact D:

    let contactD = Contact.stub("D")
    saveAssertion.expectValue()
    saveAssertion.expectCompletion()
    fetchAssertion.expectValue()
    saveAssertion.subscribe(to: save(contactD))
    saveAssertion.waitForValues()
    saveAssertion.waitForCompletion()
    fetchAssertion.waitForValues()

    XCTAssertNoDifference(saveAssertion.receivedValues(), [contactD])
    XCTAssert(saveAssertion.receivedCompletion()?.isFinished == true)
    XCTAssertNoDifference(fetchAssertion.receivedValues(), [[updatedContactA, updatedContactB, contactD]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Check if fetch publisher completed:

    XCTAssertNil(fetchAssertion.receivedCompletion())
  }

  func testFetchingAuthorized() throws {
    let fetch: Contact.Fetch = db.fetch(Contact.request(_:))

    // Mock up contacts:

    let contactA = try db.save(Contact.stub("A", authorized: true))
    let contactB = try db.save(Contact.stub("B", authorized: false))
    let contactC = try db.save(Contact.stub("C", authorized: true))
    let contactD = try db.save(Contact.stub("D", authorized: false))

    // Fetch authorized contacts:

    XCTAssertNoDifference(try fetch(Contact.Query(
      authorized: true,
      sortBy: .username()
    )), [
      contactA,
      contactC,
    ])

    // Fetch unauthorized contacts:

    XCTAssertNoDifference(try fetch(Contact.Query(
      authorized: false,
      sortBy: .username()
    )), [
      contactB,
      contactD,
    ])

    // Fetch all contacts:

    XCTAssertNoDifference(try fetch(Contact.Query(
      authorized: nil,
      sortBy: .username()
    )), [
      contactA,
      contactB,
      contactC,
      contactD,
    ])
  }

  func testFetchingAuthRequest() throws {
    let fetch: Contact.Fetch = db.fetch(Contact.request(_:))

    // Mock up contacts:

    let contactA = try db.save(Contact.stub("A", authRequest: .unknown))
    let contactB = try db.save(Contact.stub("B", authRequest: .sent))
    let contactC = try db.save(Contact.stub("C", authRequest: .received))
    let contactD = try db.save(Contact.stub("D", authRequest: .unknown))
    let contactE = try db.save(Contact.stub("E", authRequest: .sent))
    let contactF = try db.save(Contact.stub("F", authRequest: .received))

    // Fetch contacts with unknown auth request status:

    XCTAssertNoDifference(try fetch(Contact.Query(
      authRequest: [.unknown],
      sortBy: .username()
    )), [
      contactA,
      contactD,
    ])

    // Fetch contacts with auth request sent:

    XCTAssertNoDifference(try fetch(Contact.Query(
      authRequest: [.sent],
      sortBy: .username()
    )), [
      contactB,
      contactE,
    ])

    // Fetch contacts with auth request received:

    XCTAssertNoDifference(try fetch(Contact.Query(
      authRequest: [.received],
      sortBy: .username()
    )), [
      contactC,
      contactF,
    ])

    // Fetch contact with auth request sent OR received:

    XCTAssertNoDifference(try fetch(Contact.Query(
      authRequest: [.sent, .received],
      sortBy: .username()
    )), [
      contactB,
      contactC,
      contactE,
      contactF,
    ])

    // Fetch all contacts, regardless auth request status:

    XCTAssertNoDifference(try fetch(Contact.Query(
      authRequest: nil,
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
