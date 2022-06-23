import Foundation

/// Represents file transfer
public struct FileTransfer: Identifiable, Equatable, Hashable, Codable {
  /// Unique identifier of the file transfer
  public typealias ID = Data

  /// Instantiate file transfer representation
  /// - Parameters:
  ///   - id: Unique identifier of the file transfer.
  ///   - contactId: Contact id.
  ///   - name: File name.
  ///   - type: File type.
  ///   - data: File data (defaults to `nil`).
  ///   - progress: Transfer progress (0...1) (defaults to `0`).
  ///   - isIncoming: A flag determining if the transfer is incoming or outgoing.
  ///   - createdAt: Creation date (defaults to current date).
  public init(
    id: FileTransfer.ID,
    contactId: Contact.ID,
    name: String,
    type: String,
    data: Data? = nil,
    progress: Float = 0,
    isIncoming: Bool,
    createdAt: Date = Date()
  ) {
    self.id = id
    self.contactId = contactId
    self.name = name
    self.type = type
    self.data = data
    self.progress = progress
    self.isIncoming = isIncoming
    self.createdAt = createdAt
  }

  /// Unique identifier of the file transfer
  public var id: ID

  /// Contact id
  public var contactId: Contact.ID

  /// File name
  public var name: String

  /// File type
  public var type: String

  /// File data
  public var data: Data?

  /// Transfer progress (0...1)
  public var progress: Float

  /// A flag determining if the transfer is incoming or outgoing
  public var isIncoming: Bool

  /// Creation date
  public var createdAt: Date
}

extension FileTransfer {
  /// Fetch file transfer operation
  public typealias Fetch = XXModels.Fetch<FileTransfer, Query>

  /// Fetch file transfer operation publisher
  public typealias FetchPublisher = XXModels.FetchPublisher<FileTransfer, Query>

  /// Save file transfer operation publisher
  public typealias Save = XXModels.Save<FileTransfer>

  /// Delete file transfer operation publisher
  public typealias Delete = XXModels.Delete<FileTransfer>

  /// Query used for fetching file transfers
  public struct Query: Equatable {
    /// File transfers sort order
    public enum SortOrder: Equatable {
      /// Sort by creation date
      ///
      /// - Parameters:
      ///   - desc: Sort in descending order (defaults to `false`)
      case createdAt(desc: Bool = false)
    }

    /// Instantiate file transfer query
    ///
    /// - Parameters:
    ///   - id: Filter by file transfer id (defaults to `nil`).
    ///   - contactId: Filter by contact id (defaults to `nil`).
    ///   - isIncoming: Filter by incoming/outgoing status (defaults to `nil`).
    ///   - sortBy: Sort order (defaults to `.createdAt(desc: true)`).
    public init(
      id: Set<FileTransfer.ID>? = nil,
      contactId: Contact.ID? = nil,
      isIncoming: Bool? = nil,
      sortBy: SortOrder = .createdAt(desc: true)
    ) {
      self.id = id
      self.contactId = contactId
      self.isIncoming = isIncoming
      self.sortBy = sortBy
    }

    /// Filter by id
    public var id: Set<FileTransfer.ID>?

    /// Filter by contact id
    public var contactId: Contact.ID?

    /// Filter by incoming/outgoing status
    public var isIncoming: Bool?

    /// Sort order
    public var sortBy: SortOrder
  }
}
