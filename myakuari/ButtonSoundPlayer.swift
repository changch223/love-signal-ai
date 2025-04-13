//
//  Untitled.swift
//  myakuari
//
//  Created by chang chiawei on 2025-04-13.
//

import AVFoundation

class ButtonSoundPlayer {
    static var player: AVAudioPlayer?

    static func playSound() {
        guard let url = Bundle.main.url(forResource: "click", withExtension: "mp3") else {
            print("Button sound file not found")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Failed to play button sound: \(error)")
        }
    }
}
