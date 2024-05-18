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
  static let motionControlKey = "motion-enabled"
  static let motionSensitivityKey = "countdown-sounds"

  static let maxMotionSensitivity = 5
  static let delaySeconds = 1.0
  
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
    UserDefaults.standard.setValue(false, forKey: motionControlKey)
    UserDefaults.standard.set(1, forKey: motionSensitivityKey)
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
  static var motionControlEnabled: Bool {
    return UserDefaults.standard.bool(forKey: motionControlKey)
  }
  static var motionSensitivity: Int {
    return UserDefaults.standard.integer(forKey: motionSensitivityKey)
  }
  static func setDurationControl(_ number: Float) {
    UserDefaults.standard.set(number, forKey: durationControlRowKey)
  }
  static func setIntervalControl(_ number: Float) {
    UserDefaults.standard.set(number, forKey: intervalControlRowKey)
  }
  static func setMotionControl(_ enabled: Bool) {
    UserDefaults.standard.setValue(enabled, forKey: motionControlKey)
  }
  static func setMotionSensitivity(_ sensitivity: Int) {
    UserDefaults.standard.setValue(sensitivity, forKey: motionSensitivityKey)
  }
}
