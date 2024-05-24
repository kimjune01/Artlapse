//
//  Defaults.swift
//  Videlay
//
//  Created by June Kim on 5/15/24.
//

import Foundation

class Defaults {
  private static let std = UserDefaults.standard
  // Floats represent seconds
  static let durationControlRowKey = "durationControlRowKey"
  static let intervalControlRowKey = "intervalControlRowKey"
  static let motionControlKey = "motion-enabled"
  static let motionSensitivityKey = "countdown-sounds"
  static let watermarkKey = "watermark-preference"

  static let maxMotionSensitivity: Float = 5.0
  static let delaySeconds = 1.0
  
  static var isFirstLaunch: Bool {
    return !std.bool(forKey: "firstlaunch")
  }
  static func setFirstLaunchFlag() {
    std.setValue(true, forKey: "firstlaunch")
  }
  // Guarantees non-nil values for defaults
  static func setDefaultValues() {
    std.set(9.0, forKey: durationControlRowKey)
    std.set(1.0, forKey: intervalControlRowKey)
    std.setValue(false, forKey: motionControlKey)
    std.set(1.0, forKey: motionSensitivityKey)
    std.set(true, forKey: watermarkKey)
  }
  
  static var durationControl: Float {
    return std.float(forKey: durationControlRowKey)
  }
  static var intervalControl: Float {
    return std.float(forKey: intervalControlRowKey)
  }
  static var countdownSoundControl: Bool {
    return std.bool(forKey: "countdown-sounds")
  }
  static var motionControlEnabled: Bool {
    return std.bool(forKey: motionControlKey)
  }
  static var motionSensitivity: Float {
    return std.float(forKey: motionSensitivityKey)
  }
  static var watermarkPreference: Bool {
    return std.bool(forKey: watermarkKey)
  }
  
  static func setDurationControl(_ number: Float) {
    std.set(number, forKey: durationControlRowKey)
  }
  static func setIntervalControl(_ number: Float) {
    std.set(number, forKey: intervalControlRowKey)
  }
  static func setMotionControl(_ enabled: Bool) {
    std.setValue(enabled, forKey: motionControlKey)
  }
  static func setMotionSensitivity(_ sensitivity: Float) {
    std.setValue(sensitivity, forKey: motionSensitivityKey)
  }
  static func setWatermarkPreference(_ pref: Bool) {
    std.setValue(pref, forKey: watermarkKey)
  }
}
