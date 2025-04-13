//
//  Untitled.swift
//  myakuari
//
//  Created by chang chiawei on 2025-04-13.
//

import AVFoundation

class SoundManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer?
    private var nextPlayer: AVAudioPlayer?
    
    private var audioEngine: AVAudioEngine?
    private var pitchControl: AVAudioUnitTimePitch?
    private var audioPlayerNode: AVAudioPlayerNode?
    
    func playSound() {
        guard let successURL = Bundle.main.url(forResource: "success", withExtension: "mp3"),
              let myakuariURL = Bundle.main.url(forResource: "myakuari", withExtension: "mp3") else {
            print("🎵 Sound file not found")
            return
        }
        
        do {
            // 播 success.mp3
            player = try AVAudioPlayer(contentsOf: successURL)
            player?.delegate = self
            player?.play()
            
            // 預先記錄 myakuariURL
            nextPlayer = try AVAudioPlayer(contentsOf: myakuariURL)
            nextPlayer?.prepareToPlay()
            
        } catch {
            print("🎵 Failed to play sound: \(error)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // 播 myakuari.mp3 拉高音版
        playMyakuariWithPitch()
    }
    
    private func playMyakuariWithPitch() {
        guard let myakuariURL = Bundle.main.url(forResource: "myakuari", withExtension: "mp3") else {
            print("🎵 Myakuari sound file not found")
            return
        }
        
        audioEngine = AVAudioEngine()
        pitchControl = AVAudioUnitTimePitch()
        audioPlayerNode = AVAudioPlayerNode()
        
        guard let audioEngine = audioEngine,
              let pitchControl = pitchControl,
              let audioPlayerNode = audioPlayerNode else { return }
        
        let audioFile: AVAudioFile
        do {
            audioFile = try AVAudioFile(forReading: myakuariURL)
        } catch {
            print("🎵 Failed to load audio file: \(error)")
            return
        }
        
       
        
        audioEngine.attach(audioPlayerNode)
        audioEngine.attach(pitchControl)
        
        audioEngine.connect(audioPlayerNode, to: pitchControl, format: audioFile.processingFormat)
        audioEngine.connect(pitchControl, to: audioEngine.outputNode, format: audioFile.processingFormat)
        
        do {
            try audioEngine.start()
            
            // ✅ 拉高音量到 3倍（1.0 是正常，設成 3.0 就是三倍大）
            audioPlayerNode.volume = 6.0
            
            audioPlayerNode.scheduleFile(audioFile, at: nil)
            audioPlayerNode.play()
            
        } catch {
            print("🎵 Audio Engine Error: \(error)")
        }
    }
}
