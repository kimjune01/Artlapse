//
//  ClockRunloop.swift
//  Videlay
//
//  Created by June Kim on 10/9/22.
//

import Foundation
import UIKit

protocol ClockRunloopDelegate: AnyObject {
  func clockDidCycleLoop()
}

// can start, pause, stop in one-second increments
// loopSeconds may change
class ClockRunloop {
  var loopSeconds: Float = -1
  weak var delegate: ClockRunloopDelegate?
  
  var miniTimer: Timer?
  func start() {
    assert(loopSeconds > 0)
    miniTimer = Timer.scheduledTimer(withTimeInterval: Double(loopSeconds), 
                                     repeats: true,
                                     block: { [weak self] timer in
      guard let self = self else { return }
      self.delegate?.clockDidCycleLoop()
    })
    RunLoop.main.add(miniTimer!, forMode: .common)
  }
  func stop() {
    miniTimer?.invalidate()
  }
}
