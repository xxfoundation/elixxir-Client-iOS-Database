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

  func testFetchingConnected() throws {
    let fetch: Contact.Fetch = db.fetch(Contact.request(_:))

    // Mock up contacts:

    let contactA = try db.save(Contact.stub("A", connected: true))
    let contactB = try db.save(Contact.stub("B", connected: false))
    let contactC = try db.save(Contact.stub("C", connected: true))
    let contactD = try db.save(Contact.stub("D", connected: false))

    // Fetch connected contacts:

    XCTAssertNoDifference(try fetch(Contact.Query(
      sortBy: .username(),
      connected: true
    )), [
      contactA,
      contactC,
    ])

    // Fetch not connected contacts:

    XCTAssertNoDifference(try fetch(Contact.Query(
      sortBy: .username(),
      connected: false
    )), [
      contactB,
      contactD,
    ])

    // Fetch all contacts:

    XCTAssertNoDifference(try fetch(Contact.Query(
      sortBy: .username(),
      connected: nil
    )), [
      contactA,
      contactB,
      contactC,
      contactD,
    ])
  }
}
