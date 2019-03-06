//
//  AudioController.swift
//  SwiftAudio_Example
//
//  Created by Jørgen Henrichsen on 25/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import SwiftAudio


class AudioController {
    
    static let shared = AudioController()
    let player: QueuedAudioPlayer
    let audioSessionController = AudioSessionController.shared
    
    let sources: [AudioItem] = [
        DefaultAudioItem(audioUrl: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview122/v4/46/66/84/4666846c-65d5-4df7-6aae-38cf1bf758ac/mzaf_6839622279477674072.plus.aac.p.m4a", artist: "Havana Brown", title: "Havana", albumTitle: "Havana", sourceType: .stream, artwork: #imageLiteral(resourceName: "cover")),
        DefaultAudioItem(audioUrl: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/Music/v4/c6/bd/e8/c6bde863-ddce-00a5-1821-e619f3d8dfb0/mzaf_7433378345112853841.plus.aac.p.m4a", artist: "Demi Lovato", title: "Heart Attack", albumTitle: "Demi", sourceType: .stream, artwork: #imageLiteral(resourceName: "22AMI"))
    ]
    
    init() {
        let controller = RemoteCommandController()
        player = QueuedAudioPlayer(remoteCommandController: controller)
        player.remoteCommands = [
            .stop,
            .play,
            .pause,
            .togglePlayPause,
            .next,
            .previous,
            .changePlaybackPosition
        ]
        try? audioSessionController.set(category: .playback)
        try? player.add(items: sources, playWhenReady: false)
    }
    
}
