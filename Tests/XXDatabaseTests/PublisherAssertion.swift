import Combine
import XCTest

/// Test assertion for Combine's publishers
final class PublisherAssertion<Output, Failure: Error> {
  init() {}

  /// Set up expectation for receiving values with provided count
  /// - Parameter count: Number of expected values
  func expectValues(count: Int) {
    values = []
    valuesExpectation = XCTestExpectation()
    valuesExpectation?.expectationDescription = "PublisherAssertion.valuesExpectation"
    valuesExpectation?.expectedFulfillmentCount = count
  }

  /// Set up expectation for receiving a single value
  func expectValue() {
    expectValues(count: 1)
  }

  /// Set up expectation for receiving completion
  func expectCompletion() {
    completion = nil
    completionExpectation = XCTestExpectation()
    completionExpectation?.expectationDescription = "PublisherAssertion.completionExpectation"
  }

  /// Subscribe to the provided publisher
  /// - Parameter publisher: Tested publisher
  func subscribe<P: Publisher>(to publisher: P)
  where P.Output == Output, P.Failure == Failure {
    cancellable = publisher.sink(
      receiveCompletion: { [weak self] completion in
        self?.completion = completion
        self?.completionExpectation?.fulfill()
      },
      receiveValue: { [weak self] value in
        self?.values.append(value)
        self?.valuesExpectation?.fulfill()
      }
    )
  }

  /// Wait till expected number of values are received
  /// - Parameters:
  ///   - timeout: Waiting timeout (defaults to 1 second)
  func waitForValues(
    timeout: TimeInterval = 1,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    guard let expectation = valuesExpectation else {
      XCTFail("Expectation is not set up. Call `expectValues` first!", file: file, line: line)
      return
    }
    XCTWaiter().wait(for: [expectation], timeout: timeout)
    valuesExpectation = nil
  }

  /// Wait till completion is received
  /// - Parameters:
  ///   - timeout: Waiting timeout (defaults to 1 second)
  func waitForCompletion(
    timeout: TimeInterval = 1,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    guard let expectation = completionExpectation else {
      XCTFail("Expectation is not set up. Call `expectCompletion` first!", file: file, line: line)
      return
    }
    XCTWaiter().wait(for: [expectation], timeout: timeout)
    completionExpectation = nil
  }

  /// Returns values received from the publisher
  /// - Returns: Publisher's output values
  func receivedValues() -> [Output] {
    defer { values = [] }
    return values
  }

  /// Returns completion received from the publisher
  /// - Returns: Publisher's completion
  func receivedCompletion() -> Subscribers.Completion<Failure>? {
    defer { completion = nil }
    return completion
  }

  private var cancellable: AnyCancellable?
  private var valuesExpectation: XCTestExpectation?
  private var completionExpectation: XCTestExpectation?
  private var values: [Output] = []
  private var completion: Subscribers.Completion<Failure>?
}

extension Subscribers.Completion {
  /// Returns true if publisher completed successfully
  var isFinished: Bool {
    switch self {
    case .finished:
      return true
    case .failure(_):
      return false
    }
  }

  /// Returns Failure is publisher completed with it
  func getFailure() -> Failure? {
    switch self {
    case .finished:
      return nil
    case .failure(let failure):
      return failure
    }
  }
}
