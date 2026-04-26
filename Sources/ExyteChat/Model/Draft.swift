//
//  Created by Alex.M on 17.06.2022.
//

import Foundation
#if canImport(GiphyUISDK)
import GiphyUISDK
#else
public struct GPHMedia: Sendable, Equatable {
    public let id: String?

    public init(id: String? = nil) {
        self.id = id
    }
}
#endif

public struct DraftMessage: Sendable {
    public var id: String?
    public let text: String
    public let medias: [Media]
    public let giphyMedia: GPHMedia?
    public let recording: Recording?
    public let replyMessage: ReplyMessage?
    public let createdAt: Date
    
    public init(id: String? = nil,
                text: String,
                medias: [Media],
                giphyMedia: GPHMedia?,
                recording: Recording?,
                replyMessage: ReplyMessage?,
                createdAt: Date) {
        self.id = id
        self.text = text
        self.medias = medias
        self.giphyMedia = giphyMedia
        self.recording = recording
        self.replyMessage = replyMessage
        self.createdAt = createdAt
    }
}
