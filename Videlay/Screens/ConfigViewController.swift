//
//  ConfigViewController.swift
//  Videlay
//
//  Created by June Kim on 10/9/22.
//

import UIKit

protocol ConfigViewControllerDelegate: AnyObject {
  func configVCDidChangeConfig()
}

enum ConfigType: Int {
  case duration
  case interval
}

class ConfigViewController: UIViewController {
  
  let durationControlTag = 0
  let intervalControlTag = 1
  
  var durationControl: UITextField!
  var intervalControl: UITextField!
  var soundSwitch: UISwitch!

  weak var delegate: ConfigViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    addChevron()
    addControlStack()
    addTapTarget()
  }
  
  func addTapTarget() {
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapBackground))
    view.addGestureRecognizer(tapRecognizer)
  }
  
  @objc func didTapBackground() {
    view.endEditing(false)
  }
  
  func addChevron() {
    let chevron = UIImageView(image: UIImage(systemName: "chevron.down")!)
    view.addSubview(chevron)
    chevron.pinTopToParent(margin: 8, insideSafeArea: true)
    chevron.centerXInParent()
  }
  
  func addControlStack() {
    let controlStack = UIStackView()
    controlStack.axis = .vertical
    controlStack.alignment = .center
    view.addSubview(controlStack)
    controlStack.centerXInParent()
    controlStack.setTopToParent(margin: 50)

    let durationControlRow = UIStackView()
    durationControlRow.axis = .horizontal
    durationControlRow.alignment = .fill
    controlStack.addArrangedSubview(durationControlRow)
    durationControlRow.set(width: UIScreen.main.bounds.width - 10)
    durationControlRow.set(height: 45)
    
    let padding = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 75))
    controlStack.addArrangedSubview(padding)

    let durationLabel = UILabel()
    durationLabel.text = "Record duration (seconds)"
    durationLabel.font = .systemFont(ofSize: 16)
    durationLabel.textColor = .black
    durationLabel.textAlignment = .center
    durationControlRow.addArrangedSubview(durationLabel)

    durationControl = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    controlStack.addArrangedSubview(durationControl)
    durationControl.tag = durationControlTag
    durationControl.set(width: 100)
    durationControl.set(height: 65)
    durationControl.keyboardType = .decimalPad
    durationControl.text = String(format:"%.1f",Defaults.durationControl)
    durationControl.textColor = .black
    durationControl.textAlignment = .center
    durationControl.backgroundColor = .lightGray.withAlphaComponent(0.5)
    durationControl.layer.cornerRadius = 8
    durationControl.delegate = self
    
    let intervalControlRow = UIStackView()
    intervalControlRow.axis = .horizontal
    intervalControlRow.alignment = .fill
    controlStack.addArrangedSubview(intervalControlRow)
    intervalControlRow.set(width: UIScreen.main.bounds.width - 10)
    intervalControlRow.set(height: 45)

    let padding2 = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 75))
    controlStack.addArrangedSubview(padding2)

    let intervalLabel = UILabel()
    intervalLabel.text = "Interval between (seconds)"
    intervalLabel.textAlignment = .center
    intervalLabel.font = .systemFont(ofSize: 16)
    intervalLabel.textColor = .black
    intervalControlRow.addArrangedSubview(intervalLabel)
    
    intervalControl = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    controlStack.addArrangedSubview(intervalControl)
    intervalControl.tag = intervalControlTag
    intervalControl.set(width: 100)
    intervalControl.set(height: 65)
    intervalControl.textColor = .black
    intervalControl.textAlignment = .center
    intervalControl.keyboardType = .numberPad
    intervalControl.text = String(format:"%.0f",Defaults.intervalControl)
    intervalControl.delegate = self
    intervalControl.backgroundColor = .lightGray.withAlphaComponent(0.5)
    intervalControl.layer.cornerRadius = 8
    
    
//    let padding3 = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 95))
//    controlStack.addArrangedSubview(padding3)
//    
//    let soundLabel = UILabel()
//    soundLabel.text = "Recording countdown sound"
//    soundLabel.font = .systemFont(ofSize: 16)
//    soundLabel.textColor = .black
//    soundLabel.textAlignment = .center
//    controlStack.addArrangedSubview(soundLabel)
//    soundLabel.set(height: 50)
//    
//    soundSwitch = UISwitch()
//    soundSwitch.isOn = Defaults.countdownSoundControl
//    soundSwitch.addTarget(self, action: #selector(soundSwitchDidToggle), for: .valueChanged)
//    controlStack.addArrangedSubview(soundSwitch)
    
  }
  
  @objc func soundSwitchDidToggle(sw: UISwitch) {
    UserDefaults.standard.setValue(sw.isOn, forKey: "countdown-sounds")
  }
  
  static func interval(for intervalRow: Int) -> Float {
    let kink: Float = 60
    let fiveIncrements = Float(intervalRow + 1) * 5
    if fiveIncrements < kink { // Seconds
      return fiveIncrements
    }
    return Float(intervalRow + 1) * 5
  }
  
  static func configuredDurationText() -> String {
    return String(format: "%.1f", Defaults.durationControl)
  }
  
  static func configuredIntervalText() -> String {
    return String(format: "%d", Int(Defaults.intervalControl))
  }
  
  func setDuration(_ number: Float) {
    guard number >= 0.1, number < 60 else {
      showAlert("Duration should be between 0.1 and 60 seconds")
      return
    }
    Defaults.setDurationControl(number)
  }

  func setInterval(_ number: Float) {
    guard number > 1, number < 3600 else {
      showAlert("Duration should be between 1 and 3600 seconds")
      return
    }
    Defaults.setIntervalControl(number)
  }
  
  func showAlert(_ message: String) {
    let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
      
    }
    alert.addAction(okAction)
    present(alert, animated: true)
    
  }
}

extension ConfigViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return true
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    let newPosition = textField.endOfDocument
    textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    guard let text = textField.text,
    let number = Float(text) else {
      showAlert("Input a number")
      return
    }
    if textField.tag == durationControlTag {
      setDuration(number)
    }
    if textField.tag == intervalControlTag {
      setInterval(number)
    }
  }
}
