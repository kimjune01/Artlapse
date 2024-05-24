//
//  MotionHelper.swift
//  Videlay
//
//  Created by June Kim on 5/18/24.
//

import Foundation
import Vision

class MotionHelper {
  let contourRequest = MotionHelper.makeContoursRequest()
  var contourCount = -1
  var motionSensed: Float = 0

  static var sampleThrottleCounter = 0
  static let ThrottleCycle = 4
  static func makeContoursRequest() -> VNDetectContoursRequest {
    let req = VNDetectContoursRequest()
    req.revision = VNDetectContourRequestRevision1
    req.contrastAdjustment = 2
    req.maximumImageDimension = 512
    return req
  }
  
  var didSenseMotion: Bool {
    guard let observation = contourRequest.results?.first else { return false }
    let oldCount = contourCount
    contourCount = Int(Float(oldCount) * 0.7 + Float(observation.contourCount) * 0.3)
    guard oldCount > 0 else { return false }
    let diff = abs(oldCount - observation.contourCount)
    guard diff > 0 else {
      motionSensed = 0
      return false
    }
    let motionSensed = log2(Float(diff))
    DispatchQueue.main.async {
      self.motionSensed = motionSensed
    }
    let threshold = Defaults.maxMotionSensitivity - Defaults.motionSensitivity
    return motionSensed > threshold
  }
}
