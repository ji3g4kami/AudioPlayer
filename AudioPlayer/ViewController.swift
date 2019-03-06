//
//  ViewController.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 03/11/2018.
//  Copyright (c) 2018 Jørgen Henrichsen. All rights reserved.
//

import UIKit
import SwiftAudio
import AVFoundation
import MediaPlayer


class ViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    var isScrubbing: Bool = false
    let controller = AudioController.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        controller.player.delegate = self
    }
    
    @IBAction func togglePlay(_ sender: Any) {
        if (!controller.audioSessionController.audioSessionIsActive) {
            try? controller.audioSessionController.activateSession()
        }
        controller.player.togglePlaying()
    }
    
    @IBAction func previous(_ sender: Any) {
        try? controller.player.previous()
    }
    
    @IBAction func next(_ sender: Any) {
        try? controller.player.next()
    }
    
    @IBAction func startScrubbing(_ sender: UISlider) {
        isScrubbing = true
    }
    
    @IBAction func scrubbing(_ sender: UISlider) {
        controller.player.seek(to: Double(slider.value))
    }
    
    @IBAction func scrubbingValueChanged(_ sender: UISlider) {
        let value = Double(slider.value)
        elapsedTimeLabel.text = value.secondsToString()
        remainingTimeLabel.text = (controller.player.duration - value).secondsToString()
    }
}

extension ViewController: AudioPlayerDelegate {
    func audioPlayer(itemPlaybackEndedWithReason reason: PlaybackEndedReason) {
        
    }
    
    
    func audioPlayer(playerDidChangeState state: AVPlayerWrapperState) {
        print("Player State:", state)
        playButton.setTitle(state == .playing ? "Pause" : "Play", for: .normal)
        slider.maximumValue = Float(controller.player.duration)
        slider.setValue(Float(controller.player.currentTime), animated: true)
        
        guard let title = controller.player.currentItem?.getTitle() else { return }
        let startTimeCount = TimeTracker.shared.getTimeArray(of: title, status: .start)?.count ?? 0
        let pauseTimeCount = TimeTracker.shared.getTimeArray(of: title, status: .pause)?.count ?? 0
        
        switch state {
        case .ready:
            
            if let item = controller.player.currentItem {
                titleLabel.text = item.getTitle()
                artistLabel.text = item.getArtist()
                item.getArtwork({ (image) in
                    self.imageView.image = image
                })
            }
            
            elapsedTimeLabel.text = controller.player.currentTime.secondsToString()
            remainingTimeLabel.text = (controller.player.duration - controller.player.currentTime).secondsToString()
            
        case .playing:
            if startTimeCount == pauseTimeCount {
                TimeTracker.shared.record(name: title , status: .start)
            }
            
        case .paused:
            if startTimeCount > pauseTimeCount {
                TimeTracker.shared.record(name: title , status: .pause)
            }
            
        case .loading:
            if let previousItem = controller.player.previousItems.last, let previousTitle = previousItem.getTitle() {
                print("previousTitle:", previousTitle)
                let startTimeCount = TimeTracker.shared.getTimeArray(of: previousTitle, status: .start)?.count ?? 0
                let pauseTimeCount = TimeTracker.shared.getTimeArray(of: previousTitle, status: .pause)?.count ?? 0
                if startTimeCount == 0 {
                    return
                } else if startTimeCount > pauseTimeCount {
                    TimeTracker.shared.record(name: previousTitle , status: .pause)
                }
            }
            
        default:
            break
        }
    }
    
    func audioPlayer(secondsElapsed seconds: Double) {
        if !isScrubbing {
            slider.setValue(Float(seconds), animated: false)
            elapsedTimeLabel.text = controller.player.currentTime.secondsToString()
            remainingTimeLabel.text = (controller.player.duration - controller.player.currentTime).secondsToString()
        }
    }
    
    func audioPlayer(failedWithError error: Error?) {
        
    }
    
    func audioPlayer(seekTo seconds: Int, didFinish: Bool) {
        isScrubbing = false
    }
    
    func audioPlayer(didUpdateDuration duration: Double) {
        slider.maximumValue = Float(controller.player.duration)
        slider.setValue(Float(controller.player.currentTime), animated: true)
        
        elapsedTimeLabel.text = controller.player.currentTime.secondsToString()
        remainingTimeLabel.text = (controller.player.duration - controller.player.currentTime).secondsToString()
    }
    
}
