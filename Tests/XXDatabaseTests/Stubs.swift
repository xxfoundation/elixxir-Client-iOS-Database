import XXModels

extension Contact {
  static func stub(_ id: Int) -> Contact {
    Contact(
      id: "contact-id-\(id)".data(using: .utf8)!,
      marshaled: "contact-marshaled-\(id)".data(using: .utf8)!,
      username: "contact-username-\(id)",
      email: "contact-\(id)@elixxir.io",
      phone: "contact-phone-\(id)",
      nickname: "contact-nickname-\(id)"
    )
  }
}
