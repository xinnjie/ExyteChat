//
//  Media.swift
//  Chat
//

import Foundation

public enum MediaType: String, Codable, Sendable {
    case image
    case video
}

public struct Media: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let type: MediaType
    public let thumbnailURL: URL
    public let fullURL: URL

    public init(id: UUID = UUID(), type: MediaType, thumbnailURL: URL, fullURL: URL) {
        self.id = id
        self.type = type
        self.thumbnailURL = thumbnailURL
        self.fullURL = fullURL
    }

    public func getThumbnailURL() async -> URL? {
        thumbnailURL
    }

    public func getURL() async -> URL? {
        fullURL
    }
}
