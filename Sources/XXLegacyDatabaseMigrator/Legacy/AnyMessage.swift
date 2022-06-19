enum AnyMessage: Equatable {
  case direct(Message)
  case group(GroupMessage)
}

extension AnyMessage {
  var payload: Payload {
    switch self {
    case .direct(let message): return message.payload
    case .group(let message): return message.payload
    }
  }
}
