import Combine
import XCTest

extension XCTestCase {
  func assert<Output: Equatable>(
    _ publisher: AnyPublisher<Output, Error>,
    publishes output: Output,
    timeout: TimeInterval = 1,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    let expectation = XCTestExpectation(
      description: "Publishes one value then finishes"
    )
    var values: [Output] = []
    var cancellable: AnyCancellable? = publisher
      .sink(
        receiveCompletion: { completion in
          guard case .finished = completion else { return }
          expectation.fulfill()
        },
        receiveValue: { value in
          guard values.isEmpty else {
            return XCTFail(
              "Expected to receive only one value, got another: (\(value))",
              file: file,
              line: line
            )
          }
          XCTAssertEqual(value, output, file: file, line: line)
          values.append(value)
        }
      )

    wait(for: [expectation], timeout: timeout)
    _ = cancellable
    cancellable = nil
  }
}
