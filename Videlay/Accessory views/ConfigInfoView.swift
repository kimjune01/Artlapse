

import UIKit

class ConfigInfoViewController: UIViewController {
  let durationLabel = UILabel()
  let intervalLabel = UILabel()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(durationLabel)
    view.addSubview(intervalLabel)
    durationLabel.font = .monospacedSystemFont(ofSize: 14, weight: .semibold)
    intervalLabel.font = .monospacedSystemFont(ofSize: 14, weight: .semibold)
    durationLabel.alpha = 0.7
    intervalLabel.alpha = 0.7

    durationLabel.pinLeadingToParent()
    durationLabel.pinTopToParent()
    
    intervalLabel.pinLeadingToParent()
    intervalLabel.pinTop(toBottomOf: durationLabel, margin: 4)
    
    refresh()
  }
  func refresh() {
    durationLabel.text = "Duration: " + ConfigViewController.configuredDurationText() + "s"
    intervalLabel.text = "Interval: " + ConfigViewController.configuredIntervalText() + "s"
  }
}
