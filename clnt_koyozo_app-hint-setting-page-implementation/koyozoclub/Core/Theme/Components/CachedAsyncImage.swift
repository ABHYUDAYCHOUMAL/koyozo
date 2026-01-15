//
//  CachedAsyncImage.swift
import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let contentMode: ContentMode
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    @State private var previousImage: UIImage? // Keep previous image for smooth transition
    @State private var isLoading = true
    @State private var currentURL: URL?
    @State private var newImageOpacity: Double = 0.0 // Control opacity of new image during transition
    
    init(
        url: URL?,
        contentMode: ContentMode = .fill,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.contentMode = contentMode
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        ZStack {
            // Show previous image during transition for smooth crossfade
            if let previousImage = previousImage {
                content(Image(uiImage: previousImage))
                    .opacity(image == nil ? 1.0 : (1.0 - newImageOpacity)) // Fade out as new image fades in
                    .animation(.easeInOut(duration: 0.5), value: newImageOpacity)
            }
            
            // Show current image with smooth fade-in
            if let image = image {
                content(Image(uiImage: image))
                    .opacity(newImageOpacity)
            }
            
            // Only show placeholder if there's no image and no previous image
            if image == nil && previousImage == nil {
                placeholder()
            }
        }
        .task(id: url) {
            await loadImage(for: url)
        }
    }
    
    private func loadImage(for url: URL?) async {
        await MainActor.run {
            // Keep previous image for smooth transition
            if currentURL != url {
                previousImage = image // Save current image as previous
                image = nil // Clear current to trigger loading
                newImageOpacity = 0.0 // Reset opacity for new image
                isLoading = true
            }
            currentURL = url
        }
        
        guard let url = url else {
            await MainActor.run {
                isLoading = false
            }
            return
        }
        
        // Try cache first
        if let cachedImage = await ImageCache.shared.getImage(for: url) {
            await MainActor.run {
                self.image = cachedImage
                self.newImageOpacity = 0.0 // Start transparent
                // Animate fade-in
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.newImageOpacity = 1.0
                }
                // Clear previous image after transition completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.previousImage = nil
                }
                self.isLoading = false
            }
            return
        }
        
        // Load from network
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let loadedImage = UIImage(data: data) {
                // Cache the image
                ImageCache.shared.setImage(loadedImage, for: url)
                await MainActor.run {
                    self.image = loadedImage
                    self.newImageOpacity = 0.0 // Start transparent
                    // Animate fade-in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.newImageOpacity = 1.0
                    }
                    // Clear previous image after transition completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        self.previousImage = nil
                    }
                    self.isLoading = false
                }
            } else {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}

// Convenience initializer for simple use cases
extension CachedAsyncImage where Content == Image, Placeholder == Color {
    init(url: URL?, contentMode: ContentMode = .fill, placeholder: Color = Color.gray.opacity(0.3)) {
        self.url = url
        self.contentMode = contentMode
        self.content = { $0.resizable() }
        self.placeholder = { placeholder }
    }
}

