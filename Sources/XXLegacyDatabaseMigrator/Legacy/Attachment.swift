import Foundation

struct Attachment: Equatable, Codable {
  enum Extension: Int64, Codable {
    case image
    case audio
  }

  var data: Data?
  var name: String
  var transferId: Data?
  var _extension: Extension
  var progress: Float = 0.0
}
