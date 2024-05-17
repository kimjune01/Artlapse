//
//  Defaults.swift
//  Videlay
//
//  Created by June Kim on 5/15/24.
//

import Foundation

class Defaults {
  // Floats represent seconds
  static let durationControlRowKey = "durationControlRowKey"
  static let intervalControlRowKey = "intervalControlRowKey"
  static let countdownSoundKey = "countdown-sounds"
  
  static var isFirstLaunch: Bool {
    return !UserDefaults.standard.bool(forKey: "firstlaunch")
  }
  static func setFirstLaunchFlag() {
    UserDefaults.standard.setValue(true, forKey: "firstlaunch")
  }
  // Guarantees non-nil values for defaults
  static func setDefaultValues() {
    UserDefaults.standard.set(9.0, forKey: durationControlRowKey)
    UserDefaults.standard.set(1.0, forKey: intervalControlRowKey)
    UserDefaults.standard.setValue(true, forKey: countdownSoundKey)
  }
  static var durationControl: Float {
    return UserDefaults.standard.float(forKey: durationControlRowKey)
  }
  static var intervalControl: Float {
    return UserDefaults.standard.float(forKey: intervalControlRowKey)
  }
  static var countdownSoundControl: Bool {
    return UserDefaults.standard.bool(forKey: "countdown-sounds")
  }
  static func setDurationControl(_ number: Float) {
    UserDefaults.standard.set(number, forKey: durationControlRowKey)
  }
  static func setIntervalControl(_ number: Float) {
    UserDefaults.standard.set(number, forKey: intervalControlRowKey)
  }
}
