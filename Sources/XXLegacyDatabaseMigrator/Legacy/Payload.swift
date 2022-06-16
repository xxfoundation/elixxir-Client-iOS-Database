struct Payload: Equatable, Codable {
  var text: String
  var reply: Reply?
  var attachment: Attachment?
}
