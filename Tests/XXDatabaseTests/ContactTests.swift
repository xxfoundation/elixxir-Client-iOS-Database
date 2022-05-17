//import Combine
//import XCTest
//import XXModels
//@testable import XXDatabase
//
//final class ContactTests: XCTestCase {
//  var db: Database!
//
//  override func setUp() async throws {
//    db = try Database.inMemory()
//  }
//
//  override func tearDown() async throws {
//    db = nil
//  }
//
//  func testDatabaseOperations() throws {
//    let insert: Contact.Insert = db.insert()
//    let fetch: Contact.Fetch = db.fetch()
//    let update: Contact.Update = db.update()
//    let delete: Contact.Delete = db.delete()
//
//    // Insert contact A:
//
//    let contactA = Contact.stub("a")
//    XCTAssertEqual(try insert(contactA), contactA)
//
//    // Insert contact B:
//
//    let contactB = Contact.stub("b")
//    XCTAssertEqual(try insert(contactB), contactB)
//
//    // Insert contact C:
//
//    let contactC = Contact.stub("c")
//    XCTAssertEqual(try insert(contactC), contactC)
//
//    // Fetch contacts:
//
//    XCTAssertEqual(
//      try fetch(
//        Contact.Query(),
//        Contact.Order.username()
//      ),
//      [contactA, contactB, contactC]
//    )
//
//    // Update contact B:
//
//    var updatedContactB = contactB
//    updatedContactB.username!.append("-updated")
//    XCTAssertEqual(try update(updatedContactB), updatedContactB)
//
//    // Fetch contacts:
//
//    XCTAssertEqual(
//      try fetch(
//        Contact.Query(),
//        Contact.Order.username(desc: true)
//      ),
//      [contactC, updatedContactB, contactA]
//    )
//
//    // Delete contact C:
//
//    XCTAssertEqual(try delete(contactC), true)
//
//    // Fetch contacts:
//
//    XCTAssertEqual(
//      try fetch(
//        Contact.Query(),
//        Contact.Order.username()
//      ),
//      [contactA, updatedContactB]
//    )
//  }
//
//  func testDatabaseOperationPublishers() {
//    let insert: Contact.InsertPublisher = db.insertPublisher()
//    let fetch: Contact.FetchPublisher = db.fetchPublisher()
//    let update: Contact.UpdatePublisher = db.updatePublisher()
//    let delete: Contact.DeletePublisher = db.deletePublisher()
//
//    let fetchAssertion = PublisherAssertion<[Contact], Error>()
//    let insertAssertion = PublisherAssertion<Contact, Error>()
//    let updateAssertion = PublisherAssertion<Contact, Error>()
//    let deleteAssertion = PublisherAssertion<Bool, Error>()
//
//    // Subscribe to fetch publisher:
//
//    fetchAssertion.expectValue()
//    fetchAssertion.subscribe(to: fetch(Contact.Query(), Contact.Order.username()))
//    fetchAssertion.waitForValues()
//
//    XCTAssertEqual(fetchAssertion.receivedValues(), [[]])
//    XCTAssertNil(fetchAssertion.receivedCompletion())
//
//    // Insert contact A:
//
//    let contactA = Contact.stub("a")
//    insertAssertion.expectValue()
//    insertAssertion.expectCompletion()
//    fetchAssertion.expectValue()
//    insertAssertion.subscribe(to: insert(contactA))
//    insertAssertion.waitForValues()
//    insertAssertion.waitForCompletion()
//    fetchAssertion.waitForValues()
//
//    XCTAssertEqual(insertAssertion.receivedValues(), [contactA])
//    XCTAssert(insertAssertion.receivedCompletion()?.isFinished == true)
//    XCTAssertEqual(fetchAssertion.receivedValues(), [[contactA]])
//    XCTAssertNil(fetchAssertion.receivedCompletion())
//
//    // Insert contact B:
//
//    let contactB = Contact.stub("b")
//    insertAssertion.expectValue()
//    insertAssertion.expectCompletion()
//    fetchAssertion.expectValue()
//    insertAssertion.subscribe(to: insert(contactB))
//    insertAssertion.waitForValues()
//    insertAssertion.waitForCompletion()
//    fetchAssertion.waitForValues()
//
//    XCTAssertEqual(insertAssertion.receivedValues(), [contactB])
//    XCTAssert(insertAssertion.receivedCompletion()?.isFinished == true)
//    XCTAssertEqual(fetchAssertion.receivedValues(), [[contactA, contactB]])
//    XCTAssertNil(fetchAssertion.receivedCompletion())
//
//    // Insert contact C:
//
//    let contactC = Contact.stub("c")
//    insertAssertion.expectValue()
//    insertAssertion.expectCompletion()
//    fetchAssertion.expectValue()
//    insertAssertion.subscribe(to: insert(contactC))
//    insertAssertion.waitForValues()
//    insertAssertion.waitForCompletion()
//    fetchAssertion.waitForValues()
//
//    XCTAssertEqual(insertAssertion.receivedValues(), [contactC])
//    XCTAssert(insertAssertion.receivedCompletion()?.isFinished == true)
//    XCTAssertEqual(fetchAssertion.receivedValues(), [[contactA, contactB, contactC]])
//    XCTAssertNil(fetchAssertion.receivedCompletion())
//
//    // Update contact B:
//
//    var updatedContactB = contactB
//    updatedContactB.username!.append("-updated")
//    updateAssertion.expectValue()
//    updateAssertion.expectCompletion()
//    fetchAssertion.expectValue()
//    updateAssertion.subscribe(to: update(updatedContactB))
//    updateAssertion.waitForValues()
//    updateAssertion.waitForCompletion()
//    fetchAssertion.waitForValues()
//
//    XCTAssertEqual(updateAssertion.receivedValues(), [updatedContactB])
//    XCTAssert(updateAssertion.receivedCompletion()?.isFinished == true)
//    XCTAssertEqual(fetchAssertion.receivedValues(), [[contactA, updatedContactB, contactC]])
//    XCTAssertNil(fetchAssertion.receivedCompletion())
//
//    // Delete contact C:
//
//    deleteAssertion.expectValue()
//    deleteAssertion.expectCompletion()
//    fetchAssertion.expectValue()
//    deleteAssertion.subscribe(to: delete(contactC))
//    deleteAssertion.waitForValues()
//    deleteAssertion.waitForCompletion()
//    fetchAssertion.waitForValues()
//
//    XCTAssertEqual(deleteAssertion.receivedValues(), [true])
//    XCTAssert(deleteAssertion.receivedCompletion()?.isFinished == true)
//    XCTAssertEqual(fetchAssertion.receivedValues(), [[contactA, updatedContactB]])
//
//    // Check if fetch publisher completed:
//
//    XCTAssertNil(fetchAssertion.receivedCompletion())
//  }
//}
//
//private extension Contact {
//  static func stub(_ id: String) -> Contact {
//    Contact(
//      id: id.data(using: .utf8)!,
//      marshaled: "\(id)-marshaled".data(using: .utf8)!,
//      username: "Contact_\(id)",
//      email: "\(id)@elixxir.io",
//      phone: "tel:\(id)",
//      nickname: "\(id)"
//    )
//  }
//}
