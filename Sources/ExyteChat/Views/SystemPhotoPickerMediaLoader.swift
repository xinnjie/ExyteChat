//
//  SystemPhotoPickerMediaLoader.swift
//  Chat
//

#if canImport(PhotosUI) && canImport(UIKit)
import AVFoundation
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
import UIKit

@MainActor
enum SystemPhotoPickerMediaLoader {
    static func loadMedia(from items: [PhotosPickerItem]) async -> [Media] {
        var medias: [Media] = []

        for item in items {
            if let media = await loadMedia(from: item) {
                medias.append(media)
            }
        }

        return medias
    }

    private static func loadMedia(from item: PhotosPickerItem) async -> Media? {
        let isVideo = item.supportedContentTypes.contains { $0.conforms(to: .movie) }

        if isVideo {
            return await loadVideo(from: item)
        } else {
            return await loadImage(from: item)
        }
    }

    private static func loadImage(from item: PhotosPickerItem) async -> Media? {
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            return nil
        }

        let url = temporaryURL(extension: "jpg")
        do {
            try data.write(to: url, options: .atomic)
            return Media(type: .image, thumbnailURL: url, fullURL: url)
        } catch {
            return nil
        }
    }

    private static func loadVideo(from item: PhotosPickerItem) async -> Media? {
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            return nil
        }

        let videoURL = temporaryURL(extension: "mov")
        do {
            try data.write(to: videoURL, options: .atomic)
            guard let thumbnailURL = makeVideoThumbnail(for: videoURL) else {
                return nil
            }
            return Media(type: .video, thumbnailURL: thumbnailURL, fullURL: videoURL)
        } catch {
            return nil
        }
    }

    private static func makeVideoThumbnail(for url: URL) -> URL? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        do {
            let imageRef = try generator.copyCGImage(at: .zero, actualTime: nil)
            let image = UIImage(cgImage: imageRef)
            guard let data = image.jpegData(compressionQuality: 0.85) else {
                return nil
            }

            let thumbnailURL = temporaryURL(extension: "jpg")
            try data.write(to: thumbnailURL, options: .atomic)
            return thumbnailURL
        } catch {
            return nil
        }
    }

    private static func temporaryURL(extension pathExtension: String) -> URL {
        FileManager.tempDirPath.appendingPathComponent(UUID().uuidString).appendingPathExtension(pathExtension)
    }
}
#endif
