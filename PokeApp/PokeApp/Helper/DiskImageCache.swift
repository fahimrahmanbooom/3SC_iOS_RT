//
//  DiskImageCache.swift
//  PokeApp
//
//  Created by Fahim Rahman on 11/5/25.
//

import UIKit

final class DiskImageCache {
    static let shared = DiskImageCache()

    private init() {}

    private let fileManager = FileManager.default

    private var cacheDirectory: URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    func getCachedImage(for url: URL) -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)

        if fileManager.fileExists(atPath: fileURL.path),
           let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            return image
        }

        return nil
    }

    func cacheImage(_ image: UIImage, for url: URL) {
        let fileURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)

        if let data = image.pngData() {
            try? data.write(to: fileURL)
        }
    }
}
