//
//  VideoPlayer.swift
//  WallStreaming
//
//  Created by Konrad Feiler on 15.04.18.
//  Copyright © 2018 Konrad Feiler. All rights reserved.
//

import SpriteKit
import AVFoundation

class VideoPlayer: NSObject {

    let scene: SKScene
    
    private let player: AVPlayer
    private let videoNode: SKVideoNode
    private var playerStateObservation: NSKeyValueObservation?
    private var timeControlStateObservation: NSKeyValueObservation?

    private(set) var playerStatus: AVPlayer.TimeControlStatus = .paused {
        didSet {
            print("\(oldValue) -> \(playerStatus)")
            if playerStatus == .waitingToPlayAtSpecifiedRate, let reason = player.reasonForWaitingToPlay {
                print("Reason: \( reason )")
            }
        }
    }

    init(streamURL: URL) {
        let playerItem = AVPlayerItem(url: streamURL)
        playerItem.preferredForwardBufferDuration = TimeInterval(1)
        
        
        player = AVPlayer(playerItem: playerItem)
        player.automaticallyWaitsToMinimizeStalling = true
        player.playImmediately(atRate: 1)
        
        videoNode = SKVideoNode(avPlayer: player)
        let size = CGSize(width: 1600, height: 900)
        videoNode.size = size
        videoNode.position = CGPoint(x: 0.5 * size.width, y: 0.5 * size.height)

        // for some reason the video is flipped by default
        videoNode.yScale = -1
        scene = SKScene(size: size)
        scene.addChild(videoNode)
        
        super.init()
        
        playerStatus = player.timeControlStatus
        timeControlStateObservation = player.observe(\.timeControlStatus) { (player, _) in
            self.playerStatus = player.timeControlStatus
        }
        playerStateObservation = player.observe(\.status, changeHandler: { (player, _) in
            print("player.status: \(player.status)")
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoPlayer.playerItemFinished(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: nil)
    }
    
    deinit {
        timeControlStateObservation?.invalidate()
        playerStateObservation?.invalidate()
    }
    
    func play() {
        print("player.status before play: \(player.status)")
        player.play()
    }
    
    func pause() {
        player.pause()
        videoNode.pause()
    }
}

extension VideoPlayer {
    
    @objc
    func playerItemFinished(_ notification: NSNotification) {
        print("Stream finished: \(notification)")
        player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
        player.play()
    }
}


extension AVPlayer.TimeControlStatus: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .paused: return "paused"
        case .playing: return "playing"
        case .waitingToPlayAtSpecifiedRate: return "waitingToPlayAtSpecifiedRate"
        }
    }
}

extension AVPlayer.Status: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .failed: return "failed"
        case .readyToPlay: return "readyToPlay"
        case .unknown: return "unknown"
        }
    }
}