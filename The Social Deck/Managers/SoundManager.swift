//
//  SoundManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import AVFoundation

/// Manages sound effects throughout the app
class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        // Configure audio session for playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    /// Check if sound effects are enabled via UserDefaults (defaults to true if not set)
    private var soundEnabled: Bool {
        if UserDefaults.standard.object(forKey: "soundEffectsEnabled") == nil {
            return true // Default to enabled
        }
        return UserDefaults.standard.bool(forKey: "soundEffectsEnabled")
    }
    
    /// Play a sound file by name
    func playSound(named soundName: String, withExtension ext: String = "mp3") {
        guard soundEnabled else { return }
        
        guard let url = Bundle.main.url(forResource: soundName, withExtension: ext) else {
            print("Sound file \(soundName).\(ext) not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
    
    /// Play button tap sound
    func playButtonTap() {
        playSound(named: "button_tap")
    }
    
    /// Play card flip sound
    func playCardFlip() {
        playSound(named: "card_flip")
    }
    
    /// Play success sound
    func playSuccess() {
        playSound(named: "success")
    }
    
    /// Play error sound
    func playError() {
        playSound(named: "error")
    }
    
    /// Play timer tick sound
    func playTimerTick() {
        playSound(named: "timer_tick")
    }
    
    /// Play game over sound
    func playGameOver() {
        playSound(named: "game_over")
    }
    
    /// Play correct answer sound
    func playCorrect() {
        playSound(named: "correct")
    }
    
    /// Play wrong answer sound
    func playWrong() {
        playSound(named: "wrong")
    }
}
