//
//  BackgroundVibrationManager.swift
//  Tempus2
//
//  Created by Ho on 4/23/25.
//  Copyright © 2025 Sola. All rights reserved.
//

import Foundation
import AVFAudio
import UIKit

class BackgroundVibrationManager {
    
    static let shared = BackgroundVibrationManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var vibrationTimers: [String: Timer] = [:]
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    private init() {
        setupAudioSession()
        prepareAudioPlayer()
    }
    
    deinit {
        stopAllVibrations()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func prepareAudioPlayer() {
        guard let soundURL = Bundle.main.url(
            forResource: "silence",
            withExtension: "wav"
        ) else {
            print("Silence audio file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
        } catch {
            print("Failed to create audio player: \(error)")
        }
    }
    
    func createVibration(at date: Date, identifier: String) {
        // 如果已有相同标识符的定时器，先停止
        stopVibration(for: identifier)
        
        let startTime = date.timeIntervalSinceNow
        guard startTime > 0 else {
            print("Start time is in the past")
            return
        }
        
        requestBackgroundTask()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + startTime) { [weak self] in
            self?.startVibrationTimer(identifier: identifier)
        }
        
        print("Created vibration for \(identifier)")
    }
    
    private func startVibrationTimer(identifier: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 确保音频播放
            if self.audioPlayer?.isPlaying == false {
                self.audioPlayer?.play()
            }
            
            // 创建新定时器
            let timer = Timer.scheduledTimer(
                withTimeInterval: 1 * TimeInterval.Second,
                repeats: true
            ) { [weak self] _ in
                
                if self?.vibrationTimers[identifier] == nil {
                    // Fails to stop the vibration without this condition!
                    return
                }
                
                // No vibration in foreground.
                if UIApplication.shared.applicationState == .active {
                    self?.stopVibration(for: identifier)
                    return
                }
                
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                print("Vibrating for \(identifier) at \(Date())")
            }
            
            // 存储定时器
            self.vibrationTimers[identifier] = timer
            RunLoop.current.add(
                timer,
                forMode: .common
            )
            
            print("Started vibration timer for \(identifier)")
        }
    }
    
    func stopVibration(for identifier: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 停止特定定时器
            if let timer = self.vibrationTimers[identifier] {
                timer.invalidate()
                self.vibrationTimers.removeValue(forKey: identifier)
            }
            
            // 如果没有其他定时器运行，停止音频和后台任务
            if self.vibrationTimers.isEmpty {
                self.audioPlayer?.stop()
                
                do {
                    try AVAudioSession.sharedInstance().setActive(
                        false,
                        options: .notifyOthersOnDeactivation
                    )
                } catch {
                    print("Failed to deactivate audio session: \(error)")
                }
                
                self.endBackgroundTask()
            }
            
            print("Stopped vibration for \(identifier)")
        }
    }
    
    func stopAllVibrations() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 停止所有定时器
            self.vibrationTimers.values.forEach { $0.invalidate() }
            self.vibrationTimers.removeAll()
            
            // 停止音频播放
            self.audioPlayer?.stop()
            
            // 重置音频会话
            do {
                try AVAudioSession.sharedInstance().setActive(
                    false,
                    options: .notifyOthersOnDeactivation
                )
            } catch {
                print("Failed to deactivate audio session: \(error)")
            }
            
            // 结束后台任务
            self.endBackgroundTask()
            
            print("Stopped all vibrations")
        }
    }
    
    private func requestBackgroundTask() {
        if backgroundTask == .invalid {
            backgroundTask = UIApplication.shared.beginBackgroundTask(
                withName: "VibrationBackgroundTask"
            ) { [weak self] in
                self?.endBackgroundTask()
            }
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}
