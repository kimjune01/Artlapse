//
//  BipPlayer.swift
//   Sequence
//
//  Created by June Kim on 9/8/21.
//

import AVFoundation


struct BipBoopPlayer {
  private static var player: AVAudioPlayer?
  private static var timer: Timer?
  private static let totalBipBoopCounts = 4
  private static var bipBoopCounter = totalBipBoopCounts
  
  public static func startCountdown() {
    timer = Timer(timeInterval: 0.95, repeats: true, block: { t in
      if bipBoopCounter < 0 { stopCountdown(); return }
      else if bipBoopCounter > 0 { bip() }
      else if bipBoopCounter == 0 { boop() }
      bipBoopCounter -= 1
    })
    RunLoop.main.add(timer!, forMode: .common)
  }
  
  public static func stopCountdown() {
    guard let timer = timer else { return }
    timer.invalidate()
    self.timer = nil
    bipBoopCounter = totalBipBoopCounts
  }
  
  private static func bip() {
    print("bip")
    play("bip")
  }
  private static func boop() {
    print("boop")
    play("boop")
  }
  private static func play(_ resource: String) {
    guard let url = Bundle.main.url(forResource: resource, withExtension: "wav") else { return }
    do {
      // the following setting must match that of other categories in the app.
      try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .measurement, options: .mixWithOthers)
      try AVAudioSession.sharedInstance().setActive(true)
      
      /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
      player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
      guard let player = player else { return }
      player.play()
    } catch let error {
      print(error.localizedDescription)
    }
  }
}

