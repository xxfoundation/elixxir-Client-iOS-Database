import Foundation

struct Reply: Equatable, Codable {
  var messageId: Data
  var senderId: Data
}
