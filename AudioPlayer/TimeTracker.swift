//
//  TimeTracker.swift
//  AudioPlayer
//
//  Created by udn on 2019/3/6.
//  Copyright © 2019 dengli. All rights reserved.
//
import Foundation

public class TimeTracker {
    
    // Singleton
    private init() {}
    public static let shared = TimeTracker()
    
    private let userDefaults = UserDefaults.standard
    open var playingMedia: String? {
        return userDefaults.string(forKey: "playingMedia")
    }
    open var mediaList: [String]? {
        return userDefaults.array(forKey: "mediaList") as? [String]
    }
    
    public enum status: String {
        case start = "startTime"
        case pause = "pauseTime"
    }
    
    public func saveToMediaList(name: String) {
        // save media name to mediaList
        if var mediaList = userDefaults.array(forKey: "mediaList") as? [String] {
            if !mediaList.contains(name) {
                mediaList.append(name)
                userDefaults.set(mediaList, forKey: "mediaList")
            }
        } else { // no records yet
            let mediaList: [String] = [name]
            userDefaults.set(mediaList, forKey: "mediaList")
        }
    }
    
    public func getTimeArray(of name: String, status: TimeTracker.status) -> [Double]? {
        let key = "\(name)_\(status.rawValue)"
        if let timeArray = userDefaults.array(forKey: key) as? [Double] {
            return timeArray
        } else {
            return nil
        }
    }
    
    public func record(name: String, status: TimeTracker.status) {
        // save media name to mediaList
        saveToMediaList(name: name)
        
        // save media name to playingMedia
        userDefaults.set(name, forKey: "playingMedia")
        
        let key = "\(name)_\(status.rawValue)"
        let currentTime = Date().timeIntervalSince1970
        // already have record
        if var timeArray = userDefaults.array(forKey: key) as? [Double] {
            timeArray.append(currentTime)
            userDefaults.set(timeArray, forKey: key)
        } else { // no record yet
            let timeArray: [Double] = [currentTime]
            userDefaults.set(timeArray, forKey: key)
        }
    }
    
    public func getTotalDuration(of name: String) -> Double? {
        guard let startTimeArray = getTimeArray(of: name, status: .start), let pauseTimeArray = getTimeArray(of: name, status: .pause), startTimeArray.count == pauseTimeArray.count else { return nil }
        let duration = pauseTimeArray.sum() - startTimeArray.sum()
        return duration
    }
    
    public func getAllRecordsDuration(completion: (String, Double?)->()) {
        mediaList?.forEach { name in
            completion(name, getTotalDuration(of: name))
        }
    }
    
    public func removeTimerRecords() {
        mediaList?.forEach { name in
            userDefaults.removeObject(forKey: "\(name)_startTime")
            userDefaults.removeObject(forKey: "\(name)_pauseTime")
        }
        userDefaults.removeObject(forKey: "mediaList")
    }
    
    @discardableResult
    public func recordPauseBeforeTermination() -> String? {
        guard let playingMedia = playingMedia else { return nil }
        let startTimeArrayCount = getTimeArray(of: playingMedia, status: .start)?.count ?? 0
        let pauseTimeArrayCount = getTimeArray(of: playingMedia, status: .pause)?.count ?? 0
        if (pauseTimeArrayCount + 1) == startTimeArrayCount {
            record(name: playingMedia, status: .pause)
            return playingMedia
        }
        return nil
    }
    
    @discardableResult
    public func popTimeArray(of name: String, status: TimeTracker.status) -> Double? {
        let key = "\(name)_\(status.rawValue)"
        if var timeArray = userDefaults.array(forKey: key) as? [Double] {
            let lastElement = timeArray.removeLast()
            userDefaults.set(timeArray, forKey: key)
            return lastElement
        } else {
            return nil
        }
    }
    
}

public extension Collection where Element: Numeric {
    /// Returns the sum of all elements in the collection
    func sum() -> Element { return reduce(0, +) }
}

public extension String {
    var withoutSpecialCharacters: String {
        return self.components(separatedBy: CharacterSet.symbols).joined(separator: "")
    }
}
