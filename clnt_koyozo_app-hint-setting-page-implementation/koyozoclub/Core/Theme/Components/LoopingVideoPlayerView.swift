//
//  LoopingVideoPlayerView.swift
//  koyozoclub
//
//  Created for seamless video looping in onboarding
//

import SwiftUI
import AVKit
import AVFoundation

struct LoopingVideoPlayerView: UIViewRepresentable {
    let videoName: String
    let isPlaying: Bool
    
    func makeUIView(context: Context) -> VideoContainerView {
        let containerView = VideoContainerView()
        containerView.backgroundColor = .clear
        
        // Try multiple paths to find video
        var url: URL?
        
        // Try 1: With subdirectory
        if let subdirUrl = Bundle.main.url(forResource: videoName, withExtension: "mp4", subdirectory: "OnboardVideo") {
            url = subdirUrl
        }
        // Try 2: With koyozoclub/OnboardVideo subdirectory
        else if let koyozoUrl = Bundle.main.url(forResource: videoName, withExtension: "mp4", subdirectory: "koyozoclub/OnboardVideo") {
            url = koyozoUrl
        }
        // Try 3: Direct in bundle root
        else if let rootUrl = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
            url = rootUrl
        }
        
        guard let videoUrl = url else {
            print("❌ Video file not found: \(videoName).mp4 - Tried: OnboardVideo/, koyozoclub/OnboardVideo/, and root")
            return containerView
        }
        
        print("✅ Video file found: \(videoUrl.path)")
        
        // Create AVPlayer
        let player = AVPlayer(url: videoUrl)
        player.isMuted = true // Mute by default for seamless experience
        
        // Create player layer
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        
        containerView.layer.addSublayer(playerLayer)
        containerView.playerLayer = playerLayer
        
        // Store player in coordinator
        context.coordinator.player = player
        context.coordinator.playerLayer = playerLayer
        
        // Set up looping
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        
        // Start playing immediately (will be controlled by updateUIView)
        player.play()
        
        return containerView
    }
    
    func updateUIView(_ uiView: VideoContainerView, context: Context) {
        // Control playback based on isPlaying
        if isPlaying {
            context.coordinator.player?.play()
        } else {
            context.coordinator.player?.pause()
        }
    }
    
    static func dismantleUIView(_ uiView: VideoContainerView, coordinator: Coordinator) {
        coordinator.player?.pause()
        coordinator.player = nil
        coordinator.playerLayer = nil
        NotificationCenter.default.removeObserver(coordinator)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var player: AVPlayer?
        var playerLayer: AVPlayerLayer?
        
        @objc func playerItemDidReachEnd(notification: Notification) {
            guard let player = player else { return }
            // Seek to beginning and play again for seamless loop
            player.seek(to: .zero)
            player.play()
        }
    }
}

// Custom UIView to handle player layer frame updates
class VideoContainerView: UIView {
    var playerLayer: AVPlayerLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}
