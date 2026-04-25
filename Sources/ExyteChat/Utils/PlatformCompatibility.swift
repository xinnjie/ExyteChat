//
//  PlatformCompatibility.swift
//  Chat
//

import SwiftUI


/// This shim layer provides a unified interface for UIKit and AppKit.
/// By aliasing platform-specific types (e.g., aliasing UIFont to NSFont on macOS),
/// we minimize changes to the core business logic while enabling cross-platform support.


#if canImport(UIKit)
import UIKit

typealias PlatformFont = UIFont
typealias PlatformEdgeInsets = UIEdgeInsets

enum PlatformScreen {
    static var width: CGFloat { UIScreen.main.bounds.width }
    static var height: CGFloat { UIScreen.main.bounds.height }
    static var scale: CGFloat { UIScreen.main.scale }
    static var isLandscape: Bool { UIDevice.current.orientation.isLandscape }
}

enum PlatformPasteboard {
    static func copy(_ string: String) {
        UIPasteboard.general.string = string
    }
}

#elseif canImport(AppKit)
import AppKit

// Alias UIKit type names to their AppKit equivalents so that shared code referencing UIFont/UIImage compiles on macOS.
// The upstream library does not plan to support macOS, so we re-implement UI-prefixed types here
// rather than wrapping them in #if guards throughout the codebase. This minimizes future rebase conflicts.
public typealias UIFont = NSFont
public typealias UIImage = NSImage
typealias PlatformFont = NSFont
// UIEdgeInsets is the custom struct defined below, not the UIKit type.
typealias PlatformEdgeInsets = UIEdgeInsets

// Reimplementation of the UIKit UIEdgeInsets type for macOS, where it does not exist natively.
// Keeping the UI-prefixed name avoids scattering #if guards in shared code and reduces rebase conflicts with upstream.
public struct UIEdgeInsets: Equatable, Sendable {
    public var top: CGFloat
    public var left: CGFloat
    public var bottom: CGFloat
    public var right: CGFloat

    public static let zero = UIEdgeInsets()

    public init(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
}

// Stub for UIKit's UIScrollView type, only exposing keyboard dismiss mode used by the chat view.
// Re-implementing with the UI-prefixed name reduces diff noise when rebasing against upstream.
public enum UIScrollView {
    public enum KeyboardDismissMode: Sendable {
        case none
        case onDrag
        case interactive
    }
}

// macOS does not have UIFontMetrics; this stub returns the font unchanged since dynamic type scaling is not applicable.
// Keeping the UI-prefixed name avoids #if guards in shared code and reduces rebase conflicts with upstream.
struct UIFontMetrics {
    static let `default` = UIFontMetrics()

    func scaledFont(for font: NSFont) -> NSFont {
        font
    }
}

extension NSFont {
    // NSFont lacks a lineHeight property; compute it from the typetric components.
    var lineHeight: CGFloat {
        ceil(ascender - descender + leading)
    }
}

enum PlatformScreen {
    static var width: CGFloat { NSScreen.main?.frame.width ?? 800 }
    static var height: CGFloat { NSScreen.main?.frame.height ?? 600 }
    static var scale: CGFloat { NSScreen.main?.backingScaleFactor ?? 1 }
    static var isLandscape: Bool { width > height }
}

enum PlatformPasteboard {
    static func copy(_ string: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
    }
}
#endif

extension PlatformEdgeInsets {
    static var chatZero: PlatformEdgeInsets {
        .zero
    }
}
