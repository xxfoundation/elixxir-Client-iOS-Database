import Foundation

/// Represents contact
public struct Contact: Identifiable, Equatable, Codable {
  /// Unique identifier of a contact
  public typealias ID = Data

  /// Represents contact authorization status
  public enum AuthStatus: String, Equatable, Codable {
    /// Not authorized
    case stranger

    /// Sending auth request to the contact
    case requesting

    /// Auth request was sent to the contact
    case requested

    /// Sending auth request to the contact failed
    case requestFailed

    /// Verifying auth request received from the contact
    case verificationInProgress

    /// Verifying auth request received from the contact succeeded
    case verified

    /// Verifying auth request received from the contact failed
    case verificationFailed

    /// Confirming auth request received from the contact
    case confirming

    /// Confirming auth request received from the contact failed
    case confirmationFailed

    /// Authorized
    case friend

    /// Auth request received from the contact was hidden
    case hidden
  }

  /// Instantiate contact representation
  ///
  /// - Parameters:
  ///   - id: Unique identifier
  ///   - marshaled: Marshaled contact data (defaults to `nil`)
  ///   - username: Contact username (defaults to `nil`)
  ///   - email: Contact email address (defaults to `nil`)
  ///   - phone: Contact phone number (defaults to `nil`)
  ///   - nickname: Contact nickname (defaults to `nil`)
  ///   - photo: Photo data (defaults to `nil`)
  ///   - authStatus: Contact authorization status (defaults to `.stranger`)
  ///   - isRecent: Flag determining recent contact status (defaults to `false`)
  ///   - createdAt: Creation date (defaults to current date)
  public init(
    id: ID,
    marshaled: Data? = nil,
    username: String? = nil,
    email: String? = nil,
    phone: String? = nil,
    nickname: String? = nil,
    photo: Data? = nil,
    authStatus: AuthStatus = .stranger,
    isRecent: Bool = false,
    createdAt: Date = Date()
  ) {
    self.id = id
    self.marshaled = marshaled
    self.username = username
    self.email = email
    self.phone = phone
    self.nickname = nickname
    self.photo = photo
    self.authStatus = authStatus
    self.isRecent = isRecent
    self.createdAt = createdAt
  }

  /// Unique identifier
  public var id: ID

  /// Marshaled contact data
  public var marshaled: Data?

  /// Contact username
  public var username: String?

  /// Contact email address
  public var email: String?

  /// Contact phone number
  public var phone: String?

  /// Contact nickname
  public var nickname: String?

  /// Photo data
  public var photo: Data?

  /// Contact authorization status
  public var authStatus: AuthStatus

  /// Flag determining recent contact status
  public var isRecent: Bool

  /// Creation date
  public var createdAt: Date
}

extension Contact {
  /// Fetch contacts operation
  public typealias Fetch = XXModels.Fetch<Contact, Query>

  /// Fetch contacts operation publisher
  public typealias FetchPublisher = XXModels.FetchPublisher<Contact, Query>

  /// Save (insert new or update existing) contact operation
  public typealias Save = XXModels.Save<Contact>

  /// Delete contact operation
  public typealias Delete = XXModels.Delete<Contact>

  /// Query used for fetching contacts
  public struct Query: Equatable {
    /// Contacts sort order
    public enum SortOrder: Equatable {
      /// Sort by `username`
      ///
      /// - Parameters:
      ///   - desc: Sort in descending order (defaults to `false`)
      case username(desc: Bool = false)

      /// Sort by `createdAt`
      ///
      /// - Parameters:
      ///   - desc: Sort in descending order (defaults to `false`)
      case createdAt(desc: Bool = false)
    }

    /// Instantiate contacts query
    ///
    /// - Parameters:
    ///   - id: Filter by id (defaults to `nil`).
    ///   - authStatus: Filter contacts by auth status.
    ///     If set, only contacts with any of the provided auth statuses will be fetched.
    ///     If `nil` (default), the filter is not used.
    ///   - sortBy: Sort order (defaults to `.username()`).
    public init(
      id: Set<Contact.ID>? = nil,
      authStatus: Set<AuthStatus>? = nil,
      sortBy: SortOrder = .username()
    ) {
      self.id = id
      self.authStatus = authStatus
      self.sortBy = sortBy
    }

    /// Filter by id
    public var id: Set<Contact.ID>?

    /// Filter contacts by auth status
    ///
    /// If set, only contacts with any of the provided auth statuses will be fetched.
    /// If `nil`, the filter is not used.
    public var authStatus: Set<AuthStatus>?

    /// Contacts sort order
    public var sortBy: SortOrder
  }
}
