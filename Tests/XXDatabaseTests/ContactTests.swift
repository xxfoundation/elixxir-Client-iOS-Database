import Combine
import XCTest
import XXModels
@testable import XXDatabase

final class ContactTests: XCTestCase {
  var db: Database!
  var cancellables: Set<AnyCancellable>!

  override func setUp() async throws {
    db = try Database.inMemory()
    cancellables = Set()
  }

  override func tearDown() async throws {
    db = nil
    cancellables = nil
  }

  func testDatabaseOperations() throws {
    let insert: Contact.Insert = db.insert()
    let fetch: Contact.Fetch = db.fetch()
    let update: Contact.Update = db.update()
    let delete: Contact.Delete = db.delete()

    let contactA = Contact.stub("a")

    XCTAssertEqual(try insert(contactA), contactA)

    let contactB = Contact.stub("b")

    XCTAssertEqual(try insert(contactB), contactB)

    let contactC = Contact.stub("c")

    XCTAssertEqual(try insert(contactC), contactC)

    XCTAssertEqual(
      try fetch(
        Contact.Query(),
        Contact.Order.username()
      ),
      [contactA, contactB, contactC]
    )

    var updatedContactB = contactB
    updatedContactB.username!.append("-updated")

    XCTAssertEqual(try update(updatedContactB), updatedContactB)

    XCTAssertEqual(
      try fetch(
        Contact.Query(),
        Contact.Order.username(desc: true)
      ),
      [contactC, updatedContactB, contactA]
    )

    XCTAssertEqual(try delete(contactC), true)

    XCTAssertEqual(
      try fetch(
        Contact.Query(),
        Contact.Order.username()
      ),
      [contactA, updatedContactB]
    )
  }

  func testDatabaseOperationPublishers() {
    let insert: Contact.InsertPublisher = db.insertPublisher()
    let fetch: Contact.FetchPublisher = db.fetchPublisher()
    let update: Contact.UpdatePublisher = db.updatePublisher()
    let delete: Contact.DeletePublisher = db.deletePublisher()

    var fetched: [[Contact]] = []
    let fetchCompletedExpectation = XCTestExpectation(
      description: "Publishes values then finishes"
    )
    fetch(Contact.Query(), Contact.Order.username())
      .prefix(6)
      .sink(
        receiveCompletion: { completion in
          guard case .finished = completion else { return }
          fetchCompletedExpectation.fulfill()
        },
        receiveValue: { fetched.append($0) }
      )
      .store(in: &cancellables)

    let contactA = Contact.stub("a")

    assert(insert(contactA), publishes: contactA)

    let contactB = Contact.stub("b")

    assert(insert(contactB), publishes: contactB)

    let contactC = Contact.stub("c")

    assert(insert(contactC), publishes: contactC)

    var updatedContactB = contactB
    updatedContactB.username!.append("-updated")

    assert(update(updatedContactB), publishes: updatedContactB)

    assert(delete(contactC), publishes: true)

    wait(for: [fetchCompletedExpectation], timeout: 2)
    XCTAssertEqual(fetched, [
      [],
      [contactA],
      [contactA, contactB],
      [contactA, contactB, contactC],
      [contactA, updatedContactB, contactC],
      [contactA, updatedContactB]
    ])
  }
}

private extension Contact {
  static func stub(_ id: String) -> Contact {
    Contact(
      id: id.data(using: .utf8)!,
      marshaled: "\(id)-marshaled".data(using: .utf8)!,
      username: "Contact_\(id)",
      email: "\(id)@elixxir.io",
      phone: "tel:\(id)",
      nickname: "\(id)"
    )
  }
}
