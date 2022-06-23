import Foundation

enum LegacyMessage: Equatable {
  case direct(Message)
  case group(GroupMessage)
}

extension LegacyMessage {
  var payload: Payload {
    switch self {
    case .direct(let message): return message.payload
    case .group(let groupMessage): return groupMessage.payload
    }
  }

  var sender: Data {
    switch self {
    case .direct(let message): return message.sender
    case .group(let groupMessage): return groupMessage.sender
    }
  }

  var receiver: Data? {
    switch self {
    case .direct(let message): return message.receiver
    case .group(_): return nil
    }
  }

  var groupId: Data? {
    switch self {
    case .direct(_): return nil
    case .group(let groupMessage): return groupMessage.groupId
    }
  }

  var uniqueId: Data? {
    switch self {
    case .direct(let message): return message.uniqueId
    case .group(let groupMessage): return groupMessage.uniqueId
    }
  }

  var timestamp: Int {
    switch self {
    case .direct(let message): return message.timestamp
    case .group(let groupMessage): return groupMessage.timestamp
    }
  }

  var unread: Bool {
    switch self {
    case .direct(let message): return message.unread
    case .group(let groupMessage): return groupMessage.unread
    }
  }

  var roundURL: String? {
    switch self {
    case .direct(let message): return message.roundURL
    case .group(let groupMessage): return groupMessage.roundURL
    }
  }
}
