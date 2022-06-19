enum AnyMessage: Equatable {
  case direct(Message)
  case group(GroupMessage)
}
