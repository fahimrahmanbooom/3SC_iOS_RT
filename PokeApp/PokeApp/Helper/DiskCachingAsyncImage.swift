//
//  DiskCachingAsyncImage.swift
//  PokeApp
//
//  Created by Fahim Rahman on 11/5/25.
//

import SwiftUI

struct DiskCachingAsyncImage<Content: View, Placeholder: View>: View {
    
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    @State private var uiImage: UIImage?

    var body: some View {
        Group {
            if let uiImage = uiImage {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }

    private func loadImage() {
        guard let url = url else { return }

        if let cached = DiskImageCache.shared.getCachedImage(for: url) {
            self.uiImage = cached
        } else {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        DiskImageCache.shared.cacheImage(image, for: url)
                        DispatchQueue.main.async {
                            self.uiImage = image
                        }
                    }
                } catch {
                    print("❌ Failed to load image from \(url): \(error)")
                }
            }
        }
    }
}
