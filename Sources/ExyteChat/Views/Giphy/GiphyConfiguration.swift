import SwiftUI

#if canImport(GiphyUISDK)
import GiphyUISDK
#endif

public struct GiphyConfiguration {
    
    public let giphyKey: String?
    public let dimBackground: Bool
    public let showConfirmationScreen: Bool
    public let shouldLocalizeSearch: Bool
    #if canImport(GiphyUISDK)
    public let mediaTypeConfig: [GiphyUISDK.GPHContentType]
    #endif
    public let presentationDetents: CGFloat
    public let showAttributionMark: Bool
    
    #if canImport(GiphyUISDK)
    public init(
        giphyKey: String? = nil,
        dimBackground: Bool = false,
        showConfirmationScreen: Bool = false,
        shouldLocalizeSearch: Bool = false,
        mediaTypeConfig: [GiphyUISDK.GPHContentType] = [.gifs, .stickers, .recents, .clips],
        presentationDetents: CGFloat = 0.9,
        showAttributionMark: Bool = false
    ) {
        self.giphyKey = giphyKey
        self.dimBackground = dimBackground
        self.showConfirmationScreen = showConfirmationScreen
        self.shouldLocalizeSearch = shouldLocalizeSearch
        self.mediaTypeConfig = mediaTypeConfig
        self.presentationDetents = presentationDetents
        self.showAttributionMark = showAttributionMark
    }
    #else
    public init(
        giphyKey: String? = nil,
        dimBackground: Bool = false,
        showConfirmationScreen: Bool = false,
        shouldLocalizeSearch: Bool = false,
        presentationDetents: CGFloat = 0.9,
        showAttributionMark: Bool = false
    ) {
        self.giphyKey = giphyKey
        self.dimBackground = dimBackground
        self.showConfirmationScreen = showConfirmationScreen
        self.shouldLocalizeSearch = shouldLocalizeSearch
        self.presentationDetents = presentationDetents
        self.showAttributionMark = showAttributionMark
    }
    #endif
}
