
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
  let sensitivityControlTag = 2
  
  var durationControl: UITextField!
  var intervalControl: UITextField!
//  var soundSwitch: UISwitch!
  var motionControlSwitch: UISwitch!
  var sensitivityControl: UITextField!
  var watermarkControlSwitch: UISwitch!
  

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
    controlStack.spacing = 18
    view.addSubview(controlStack)
    controlStack.centerXInParent()
    controlStack.setTopToParent(margin: 50)
    
    let durationControlRow = PreferenceRow(labelText: "Record duration (seconds)")
    controlStack.addArrangedSubview(durationControlRow)
    durationControlRow.set(width: view.width - 24)

    durationControl = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    durationControlRow.addArrangedSubview(durationControl)
    durationControl.tag = durationControlTag
    durationControl.text = String(format:"%.1f",Defaults.durationControl)
    configureNumbered(textfield: durationControl)
    
    let intervalControlRow = PreferenceRow(labelText: "Interval between (seconds)")
    controlStack.addArrangedSubview(intervalControlRow)
    intervalControlRow.set(width: view.width - 24)

    intervalControl = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    intervalControlRow.addArrangedSubview(intervalControl)
    intervalControl.tag = intervalControlTag
    configureNumbered(textfield: intervalControl)
    intervalControl.text = String(format:"%.0f",Defaults.intervalControl)

    let motionControlRow = PreferenceRow(labelText: "Motion control")
    controlStack.addArrangedSubview(motionControlRow)
    motionControlRow.set(width: view.width - 24)
    
    motionControlSwitch = UISwitch()
    motionControlSwitch.isOn = Defaults.motionControlEnabled
    motionControlSwitch.addTarget(self, action: #selector(motionSwitchDidToggle), for: .valueChanged)
    motionControlRow.addArrangedSubview(motionControlSwitch)
    
    let sensitivityControlRow = PreferenceRow(labelText: "Motion sensitivity (1 - 5)")
    controlStack.addArrangedSubview(sensitivityControlRow)
    sensitivityControlRow.set(width: view.width - 24)
    
    sensitivityControl = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    sensitivityControlRow.addArrangedSubview(sensitivityControl)
    sensitivityControl.tag = sensitivityControlTag
    sensitivityControl.text = String(format:".1f",Defaults.motionSensitivity)
    configureNumbered(textfield: sensitivityControl)
    
    let watermarkControlRow = PreferenceRow(labelText: "Artlapse Watermark")
    controlStack.addArrangedSubview(watermarkControlRow)
    watermarkControlRow.set(width: view.width - 24)
    
    watermarkControlSwitch = UISwitch()
    watermarkControlSwitch.isOn = Defaults.watermarkPreference
    watermarkControlSwitch.addTarget(self, action: #selector(watermarkSwitchDidToggle), for: .valueChanged)
    watermarkControlRow.addArrangedSubview(watermarkControlSwitch)
  }
  
  func configureNumbered(textfield: UITextField) {
    textfield.set(width: 100)
    textfield.set(height: 65)
    textfield.keyboardType = .decimalPad
    textfield.textColor = .black
    textfield.textAlignment = .center
    textfield.backgroundColor = .lightGray.withAlphaComponent(0.5)
    textfield.layer.cornerRadius = 8
    textfield.delegate = self
  }
  
  @objc func motionSwitchDidToggle(sw: UISwitch) {
    Defaults.setMotionControl(sw.isOn)
    if (sw.isOn) {
      showAlert("Turning on motion control will wait for a minimum of [interval] seconds, then wait for something to move.")
    } else {
      showAlert("Thanks for trying motion control! Please provide feedback via the chat button.")
    }
    delegate?.configVCDidChangeConfig()
  }
  
  @objc func watermarkSwitchDidToggle(sw: UISwitch) {
    Defaults.setWatermarkPreference(sw.isOn)
    if (sw.isOn) {
      showAlert("Thanks for supporting Artlapse!")
    }
    delegate?.configVCDidChangeConfig()
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
  
  static func configuredMotionText() -> String {
    return String(format: "%.1f", Defaults.motionSensitivity)
  }
  
  func setDuration(_ number: Float) {
    guard number >= 0.1, number < 60 else {
      showAlert("Duration should be between 0.1 and 60 seconds")
      durationControl.becomeFirstResponder()
      return
    }
    Defaults.setDurationControl(number)
  }

  func setInterval(_ number: Float) {
    guard number > 1, number < 3600 else {
      showAlert("Interval should be between 1 and 3600 seconds")
      intervalControl.becomeFirstResponder()
      return
    }
    Defaults.setIntervalControl(number)
  }
  
  func setMotionSensitivity(_ number: Float) {
    guard number >= 0.1, number <= 5 else {
      showAlert("Sensitivity should be between 0.1 and 5. 5 is most sensitive.")
      sensitivityControl.becomeFirstResponder()
      return
    }
    Defaults.setMotionSensitivity(number)
  }
  
  func showAlert(_ message: String) {
    let alert = UIAlertController(title: "Attention", message: message, preferredStyle: .alert)
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
    switch textField.tag {
    case durationControlTag:
      setDuration(number)
    case intervalControlTag:
      setInterval(number)
    case sensitivityControlTag:
      setMotionSensitivity(number)
    default:
      assert(false)
    }
    delegate?.configVCDidChangeConfig()
  }
}
