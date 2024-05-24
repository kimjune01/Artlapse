

import UIKit

class ConfigInfoViewController: UIViewController {
  let durationLabel = UILabel()
  let intervalLabel = UILabel()
  let motionLabel = UILabel()
  let senseLabel = UILabel()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(durationLabel)
    view.addSubview(intervalLabel)
    view.addSubview(motionLabel)
    view.addSubview(senseLabel)
    
    durationLabel.font = .monospacedSystemFont(ofSize: 14, weight: .semibold)
    intervalLabel.font = .monospacedSystemFont(ofSize: 14, weight: .semibold)
    motionLabel.font = .monospacedSystemFont(ofSize: 14, weight: .semibold)
    senseLabel.font = .monospacedSystemFont(ofSize: 14, weight: .semibold)
    
    durationLabel.alpha = 0.7
    intervalLabel.alpha = 0.7
    motionLabel.alpha = 0.7
    senseLabel.alpha = 0.7

    durationLabel.pinLeadingToParent()
    durationLabel.pinTopToParent()
    
    intervalLabel.pinLeadingToParent()
    intervalLabel.pinTop(toBottomOf: durationLabel, margin: 4)
    
    motionLabel.pinLeadingToParent()
    motionLabel.pinTop(toBottomOf: intervalLabel, margin: 4)
    
    senseLabel.pinLeadingToParent()
    senseLabel.pinTop(toBottomOf: motionLabel, margin: 4)
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    refresh()
  }
  
  func setMotionSense(_ sense: Float) {
    var char =  "⚪️"
    let threshold = 5.0 - Defaults.motionSensitivity
    if sense > threshold {
      char = "🟢"
    }
    let senseMeter = String(repeating: char, count: Int(sense))
    senseLabel.text = "Current motion: " + senseMeter
  }
  
  func refresh() {
    durationLabel.text = "Duration: " + ConfigViewController.configuredDurationText() + "s"
    intervalLabel.text = "Interval: " + ConfigViewController.configuredIntervalText() + "s"
    if Defaults.motionControlEnabled {
      let senseMeter = String(format: "%.1f", Defaults.motionSensitivity)

      motionLabel.text = "Motion sensitivity: " + senseMeter
      senseLabel.text = "Current motion: unknown"
    }
    motionLabel.isHidden = !Defaults.motionControlEnabled
    senseLabel.isHidden = !Defaults.motionControlEnabled
  }
}
