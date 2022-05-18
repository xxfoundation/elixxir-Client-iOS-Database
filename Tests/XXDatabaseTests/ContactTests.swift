import Combine
import XCTest
import XXModels
@testable import XXDatabase

final class ContactTests: XCTestCase {
  var db: Database!

  override func setUp() async throws {
    db = try Database.inMemory()
  }

  override func tearDown() async throws {
    db = nil
  }

  func testDatabaseOperations() throws {
    let fetch: Contact.Fetch = db.fetch(Contact.request(_:_:))
    let insert: Contact.Insert = db.insert(_:)
    let update: Contact.Update = db.update(_:)
    let save: Contact.Save = db.save(_:)
    let delete: Contact.Delete = db.delete(_:)

    // Insert contact A:

    let contactA = Contact.stub(1)
    XCTAssertEqual(try insert(contactA), contactA)

    // Insert contact B:

    let contactB = Contact.stub(2)
    XCTAssertEqual(try insert(contactB), contactB)

    // Insert contact C:

    let contactC = Contact.stub(3)
    XCTAssertEqual(try insert(contactC), contactC)

    // Fetch contacts:

    XCTAssertEqual(
      try fetch(.all, .username()),
      [contactA, contactB, contactC]
    )

    // Update contact B:

    var updatedContactB = contactB
    updatedContactB.username!.append("-updated")
    XCTAssertEqual(try update(updatedContactB), updatedContactB)

    // Fetch contacts:

    XCTAssertEqual(
      try fetch(.all, .username(desc: true)),
      [contactC, updatedContactB, contactA]
    )

    // Delete contact C:

    XCTAssertEqual(try delete(contactC), true)

    // Fetch contacts:

    XCTAssertEqual(
      try fetch(.all, .username()),
      [contactA, updatedContactB]
    )

    // Save updated contact A:

    var updatedContactA = contactA
    updatedContactA.username!.append("-updated")
    XCTAssertEqual(try update(updatedContactA), updatedContactA)

    // Fetch contacts:

    XCTAssertEqual(
      try fetch(.all, .username()),
      [updatedContactA, updatedContactB]
    )

    // Save new contact D:

    let contactD = Contact.stub(4)
    XCTAssertEqual(try save(contactD), contactD)

    // Fetch contacts:

    XCTAssertEqual(
      try fetch(.all, .username()),
      [updatedContactA, updatedContactB, contactD]
    )
  }

  func testDatabaseOperationPublishers() {
    let fetch: Contact.FetchPublisher = db.fetchPublisher(Contact.request(_:_:))
    let insert: Contact.InsertPublisher = db.insertPublisher(_:)
    let update: Contact.UpdatePublisher = db.updatePublisher(_:)
    let save: Contact.SavePublisher = db.savePublisher(_:)
    let delete: Contact.DeletePublisher = db.deletePublisher(_:)

    let fetchAssertion = PublisherAssertion<[Contact], Error>()
    let insertAssertion = PublisherAssertion<Contact, Error>()
    let updateAssertion = PublisherAssertion<Contact, Error>()
    let saveAssertion = PublisherAssertion<Contact, Error>()
    let deleteAssertion = PublisherAssertion<Bool, Error>()

    // Subscribe to fetch publisher:

    fetchAssertion.expectValue()
    fetchAssertion.subscribe(to: fetch(.all, .username()))
    fetchAssertion.waitForValues()

    XCTAssertEqual(fetchAssertion.receivedValues(), [[]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Insert contact A:

    let contactA = Contact.stub(1)
    insertAssertion.expectValue()
    insertAssertion.expectCompletion()
    fetchAssertion.expectValue()
    insertAssertion.subscribe(to: insert(contactA))
    insertAssertion.waitForValues()
    insertAssertion.waitForCompletion()
    fetchAssertion.waitForValues()

    XCTAssertEqual(insertAssertion.receivedValues(), [contactA])
    XCTAssert(insertAssertion.receivedCompletion()?.isFinished == true)
    XCTAssertEqual(fetchAssertion.receivedValues(), [[contactA]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Insert contact B:

    let contactB = Contact.stub(2)
    insertAssertion.expectValue()
    insertAssertion.expectCompletion()
    fetchAssertion.expectValue()
    insertAssertion.subscribe(to: insert(contactB))
    insertAssertion.waitForValues()
    insertAssertion.waitForCompletion()
    fetchAssertion.waitForValues()

    XCTAssertEqual(insertAssertion.receivedValues(), [contactB])
    XCTAssert(insertAssertion.receivedCompletion()?.isFinished == true)
    XCTAssertEqual(fetchAssertion.receivedValues(), [[contactA, contactB]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Insert contact C:

    let contactC = Contact.stub(3)
    insertAssertion.expectValue()
    insertAssertion.expectCompletion()
    fetchAssertion.expectValue()
    insertAssertion.subscribe(to: insert(contactC))
    insertAssertion.waitForValues()
    insertAssertion.waitForCompletion()
    fetchAssertion.waitForValues()

    XCTAssertEqual(insertAssertion.receivedValues(), [contactC])
    XCTAssert(insertAssertion.receivedCompletion()?.isFinished == true)
    XCTAssertEqual(fetchAssertion.receivedValues(), [[contactA, contactB, contactC]])
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

    XCTAssertEqual(updateAssertion.receivedValues(), [updatedContactB])
    XCTAssert(updateAssertion.receivedCompletion()?.isFinished == true)
    XCTAssertEqual(fetchAssertion.receivedValues(), [[contactA, updatedContactB, contactC]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Delete contact C:

    deleteAssertion.expectValue()
    deleteAssertion.expectCompletion()
    fetchAssertion.expectValue()
    deleteAssertion.subscribe(to: delete(contactC))
    deleteAssertion.waitForValues()
    deleteAssertion.waitForCompletion()
    fetchAssertion.waitForValues()

    XCTAssertEqual(deleteAssertion.receivedValues(), [true])
    XCTAssert(deleteAssertion.receivedCompletion()?.isFinished == true)
    XCTAssertEqual(fetchAssertion.receivedValues(), [[contactA, updatedContactB]])

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

    XCTAssertEqual(saveAssertion.receivedValues(), [updatedContactA])
    XCTAssert(saveAssertion.receivedCompletion()?.isFinished == true)
    XCTAssertEqual(fetchAssertion.receivedValues(), [[updatedContactA, updatedContactB]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Save new contact D:

    let contactD = Contact.stub(4)
    saveAssertion.expectValue()
    saveAssertion.expectCompletion()
    fetchAssertion.expectValue()
    saveAssertion.subscribe(to: save(contactD))
    saveAssertion.waitForValues()
    saveAssertion.waitForCompletion()
    fetchAssertion.waitForValues()

    XCTAssertEqual(saveAssertion.receivedValues(), [contactD])
    XCTAssert(saveAssertion.receivedCompletion()?.isFinished == true)
    XCTAssertEqual(fetchAssertion.receivedValues(), [[updatedContactA, updatedContactB, contactD]])
    XCTAssertNil(fetchAssertion.receivedCompletion())

    // Check if fetch publisher completed:

    XCTAssertNil(fetchAssertion.receivedCompletion())
  }
}
