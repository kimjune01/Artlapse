//
//  ViewController.swift
//  Videlay
//
//  Created by June Kim on 10/2/22.
//

import UIKit
import NextLevel
import AVFoundation
import Crisp
import PhotosUI
import Vision

// If motion controlled, sequence is:
//    standby -> idle -> detect motion -> delay -> active -> waiting -> idle
// If timer controlled, sequence is standby -> active -> waiting -> active
enum TimelapseState {
  case unknown
  case standby
  case activeInLoop
  case waitingInLoop
  case idleInLoop
  case delayingInLoop
}

protocol RecordingViewControllerDelegate: AnyObject {
  func gotoPreview()
}

class RecordingViewController: UIViewController {
  
  var delegate: RecordingViewControllerDelegate?
  
  let motionHelper = MotionHelper()

  let spinner = UIActivityIndicatorView(style: .large)
  var previewView = UIView()
  let minimumZoom: CGFloat = 0.5
  let maximumZoom: CGFloat = 5.0
  var lastZoomFactor: CGFloat = 1.0
  let controlsContainer = UIView()
  let recordButton = RecordButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
  
  var resetTimer: Timer!
  let clockOverlay = ClockOverlayView()
  let timerLabel = UILabel()
  
  var configButton: UIButton!
  var chatButton: UIButton!
  var previewButton: UIButton!
  var flipButton: UIButton!
  
  let configInfoVC = ConfigInfoViewController()

  var timelapseState: TimelapseState = .unknown {
    didSet {
      renderTimelapseState()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    view.backgroundColor = .darkGray
    
    setupCameraPreview()
    configureCaptureSession()
    
    addButtons()
    addClockOverlay()
    addConfigInfoView()
    addSpinner()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tryStartingRecordingSession()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
//    showConfigVC()
    configInfoVC.refresh()

  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  func setupCameraPreview() {
    let screenBounds = UIScreen.main.bounds
    previewView.frame = screenBounds
    previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    NextLevel.shared.previewLayer.frame = previewView.bounds
    previewView.layer.addSublayer(NextLevel.shared.previewLayer)
    self.view.addSubview(previewView)

  }

  func addSpinner() {
    view.addSubview(spinner)
    spinner.startAnimating()
    spinner.centerXInParent()
    spinner.centerYInParent(offset: -30)
  }
  
  func addButtons() {
    view.addSubview(controlsContainer)
    controlsContainer.fillParent()
    let pinchRecognizer = UIPinchGestureRecognizer(target: self, action:#selector(pinch(_:)))
    controlsContainer.addGestureRecognizer(pinchRecognizer)

    addChatButton()
    addRecordButton()
    addConfigButton()
    addTimerLabel()
    addPreviewButton()
    addFlipButton()
  }
  
  func addChatButton() {
    var config = UIButton.Configuration.filled()
    config.baseForegroundColor = .white
    config.baseBackgroundColor = .black.withAlphaComponent(0.3)
    config.cornerStyle = .large
    config.buttonSize = .large
    config.image = UIImage(systemName: "ellipsis.bubble.fill")!
    
    let button = UIButton(configuration: config, primaryAction: UIAction() { _ in
      self.showChatVCWithDialog()
    })
    controlsContainer.addSubview(button)
    button.pinTrailingToParent(margin: 8)
    button.pinTopToParent(margin: 8, insideSafeArea: true)
    button.isEnabled = false

    chatButton = button
  }
  
  func addRecordButton() {
    controlsContainer.addSubview(recordButton)
    recordButton.pinBottomToParent(margin: 15, insideSafeArea: true)
    recordButton.centerXInParent()
    recordButton.setSquare(constant: recordButton.defaultSize)
    recordButton.backgroundColor = .gray
    
    let recognizer = UITapGestureRecognizer(target: self, action: #selector(tappedRecordButton))
    recordButton.addGestureRecognizer(recognizer)
  }
  
  func addConfigButton() {
    var config = UIButton.Configuration.filled()
    config.baseForegroundColor = .white
    config.baseBackgroundColor = .black.withAlphaComponent(0.3)
    config.cornerStyle = .large
    config.buttonSize = .large
    config.image = UIImage(systemName: "gearshape.fill")!
    
    let button = UIButton(configuration: config, primaryAction: UIAction() { _ in
      self.showConfigVC()
    })
    controlsContainer.addSubview(button)
    button.pinLeadingToParent(margin: 8)
    button.pinTopToParent(margin: 8, insideSafeArea: true)
    button.isEnabled = false
    self.configButton = button
  }
  
  func addFlipButton() {
    var config = UIButton.Configuration.filled()
    config.baseForegroundColor = .white
    config.baseBackgroundColor = .black.withAlphaComponent(0.3)
    config.cornerStyle = .large
    config.buttonSize = .large
    config.image = UIImage(systemName: "camera.rotate")!

    let button = UIButton(configuration: config, primaryAction: UIAction() { _ in
      self.flipCamera()
    })
    controlsContainer.addSubview(button)
    button.pinLeadingToParent(margin: 12)
    button.pinBottomToParent(margin: 20, insideSafeArea: true)
    button.isEnabled = false
    self.flipButton = button

  }
  
  func addClockOverlay() {
    view.addSubview(clockOverlay)
    clockOverlay.setSquare(constant: ClockOverlayView.outerDiameter)
    clockOverlay.centerXInParent()
    clockOverlay.centerYInParent()
    clockOverlay.isUserInteractionEnabled = false
  }
  
  func addConfigInfoView() {
    view.addSubview(configInfoVC.view)
    configInfoVC.view.isUserInteractionEnabled = false
    configInfoVC.view.pinLeadingToParent(margin: 8)
    configInfoVC.view.pinTop(toBottomOf: configButton, margin: 8)
    configInfoVC.view.set(width: 300)
    configInfoVC.view.set(height: 100)
    addChild(configInfoVC)
    configInfoVC.didMove(toParent: self)
  }
    
  func showChatVCWithDialog() {
    let alertController = UIAlertController(title: "Chat with the developer", message: "I would love to know about your experience with Artlapse. Please help make this app better with feedback. I get notifications straight to my iPhone!", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Chat", style: .default, handler: { _ in
      self.present(ChatViewController(), animated: true)
    }))
    alertController.addAction(UIAlertAction(title: "Not now", style: .cancel))
    present(alertController, animated: true)
  }
  
  func showConfigVC() {
    let configVC = ConfigViewController()
    configVC.delegate = self
    present(configVC, animated: true)
  }

  func configureCaptureSession() {
    NextLevel.shared.delegate = self
    NextLevel.shared.deviceDelegate = self
    NextLevel.shared.videoDelegate = self
    
    // modify .videoConfiguration, .audioConfiguration, .photoConfiguration properties
    // Compression, resolution, and maximum recording time options are available
    NextLevel.shared.audioConfiguration.bitRate = 44000
    NextLevel.shared.isVideoCustomContextRenderingEnabled = true
    NextLevel.shared.videoStabilizationMode = .off
  }
  
  func addTimerLabel() {
    view.addSubview(timerLabel)
    timerLabel.pinTopToParent(margin: 8, insideSafeArea: true)
    timerLabel.set(height: 50)
    timerLabel.set(width: 200)
    timerLabel.centerXInParent()
    timerLabel.timeFormat()
  }
  
  func addPreviewButton() {
    var previewConfig = UIButton.Configuration.filled()
    previewConfig.baseForegroundColor = .white
    previewConfig.baseBackgroundColor = .black.withAlphaComponent(0.3)
    previewConfig.cornerStyle = .large
    previewConfig.buttonSize = .large
    previewConfig.image = UIImage(systemName: "play.rectangle.fill")

    previewButton = UIButton(configuration: previewConfig, primaryAction: UIAction() { _ in
      self.resetTimer.invalidate()
      self.timelapseState = .standby
      self.delegate?.gotoPreview()
    })
    controlsContainer.addSubview(previewButton)
    previewButton.pinTrailingToParent(margin: 12)
    previewButton.pinBottomToParent(margin: 20, insideSafeArea: true)
    previewButton.alpha = 0.3
    
  }
  
  func tryStartingRecordingSession() {
    requestPermissions() { [weak self] granted in
      guard let self = self else { return }
      guard granted else {
        self.showPermissionRequiredAlert()
        return
      }
      DispatchQueue.global().async {
        do {
          try NextLevel.shared.changeCaptureDeviceIfAvailable(captureDevice: .tripleCamera)
        } catch {
          do {
            try NextLevel.shared.changeCaptureDeviceIfAvailable(captureDevice: .duoCamera)
          } catch {
            do {
              try NextLevel.shared.changeCaptureDeviceIfAvailable(captureDevice: .dualWideCamera)
            } catch {
              print("did not change capture device")
            }
          }
        }
        do {
          NextLevel.shared.automaticallyUpdatesDeviceOrientation = true
          try NextLevel.shared.start()
          DispatchQueue.main.async {
            self.timelapseState = .standby
          }
        } catch {
          print(error)
        }
      }
    }
  }
  
  func requestPermissions(_ completion: @escaping (Bool) -> ()) {
    var audioGranted = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    var videoGranted = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    if audioGranted && videoGranted {
      completion(true)
      return
    }
    let group = DispatchGroup()
    if !audioGranted {
      group.enter()
      AVCaptureDevice.requestAccess(for: .audio){ granted in
        audioGranted = granted
        group.leave()
      }
    }
    if !videoGranted {
      group.enter()
      AVCaptureDevice.requestAccess(for: .video) { granted in
        videoGranted = granted
        group.leave()
      }
    }
    group.notify(queue: .main) {
      completion(audioGranted && videoGranted)
    }
  }
  
  func showPermissionRequiredAlert() {
    let alert = UIAlertController(title: "Need camera & microphone permission", message: "Go to the settings app to enable camera permissions for this app", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
    present(alert, animated: false)
  }
  
  func renderTimelapseState() {
    switch timelapseState {
    case .unknown:
      recordButton.backgroundColor = .gray
      recordButton.turnToRoundedRect()
      configButton.isEnabled = false
      chatButton.isEnabled = true
      previewButton.isEnabled = false
      flipButton.isEnabled = false
      timerLabel.alpha = 0.3
    case .standby:
      spinner.stopAnimating()
      recordButton.backgroundColor = .systemRed
      recordButton.turnToCircle()
      chatButton.isEnabled = true
      flipButton.isEnabled = true
      configButton.isEnabled = true
      timerLabel.alpha = 1
      if let sesh = NextLevel.shared.session {
        let hasClip = sesh.clips.count > 0
        previewButton.isEnabled = hasClip
      }
    case .activeInLoop:
      recordButton.backgroundColor = .systemPink.withAlphaComponent(0.4)
      recordButton.turnToRoundedRect()
      configButton.isEnabled = false
      chatButton.isEnabled = false
      previewButton.isEnabled = false
      flipButton.isEnabled = false
      timerLabel.alpha = 1
    case .waitingInLoop:
      recordButton.backgroundColor = .systemPink
      recordButton.turnToRoundedRect()
      configButton.isEnabled = false
      chatButton.isEnabled = false
      previewButton.isEnabled = false
      flipButton.isEnabled = false
      timerLabel.alpha = 1
    case .idleInLoop:
      recordButton.backgroundColor = .systemPink
      recordButton.turnToRoundedRect()
      configButton.isEnabled = false
      chatButton.isEnabled = false
      previewButton.isEnabled = false
      flipButton.isEnabled = false
      timerLabel.alpha = 1
      clockOverlay.cancelAnimations()
    case .delayingInLoop:
      recordButton.backgroundColor = .systemPink.withAlphaComponent(0.4)
      recordButton.turnToRoundedRect()
      configButton.isEnabled = false
      chatButton.isEnabled = false
      previewButton.isEnabled = false
      flipButton.isEnabled = false
      timerLabel.alpha = 0.3
    }
    
    previewButton.alpha = previewButton.isEnabled ? 1 : 0.3
    
    if let sesh = NextLevel.shared.session {
      let durationText = String(format: "%.1f", Float(sesh.clips.count) * Defaults.durationControl)
      timerLabel.text = "Video length: " + durationText + "s"
    }
  }
  
  @objc func pinch(_ pinch: UIPinchGestureRecognizer) {
    // Return zoom value between the minimum and maximum zoom values
    func minMaxZoom(_ factor: CGFloat) -> CGFloat {
      return min(max(factor, minimumZoom), maximumZoom)
    }
    
    let newScaleFactor = minMaxZoom(pinch.scale * lastZoomFactor)
    print(newScaleFactor)
    switch pinch.state {
    case .began: fallthrough
    case .changed:
      NextLevel.shared.videoZoomFactor = Float(newScaleFactor)
    case .ended:
      lastZoomFactor = minMaxZoom(newScaleFactor)
      NextLevel.shared.videoZoomFactor = Float(lastZoomFactor)
    default: break
    }
  }
  
  @objc func tappedRecordButton() {
    switch timelapseState {
    case .unknown:
      assert(false)
    case .standby:
      UIApplication.shared.isIdleTimerDisabled = true
      if Defaults.motionControlEnabled {
        timelapseState = .idleInLoop
        // do not start recording until motion is detected.
      } else {
        recordSegment()
      }

    case .activeInLoop:
      print("do nothing")
    case .waitingInLoop:
      suspendTimelapse()
    case .idleInLoop:
      suspendTimelapse()
    case .delayingInLoop:
      print("do nothing")
    }
  }
  
  func suspendTimelapse() {
    resetTimer.invalidate()
    clockOverlay.cancelAnimations()
    timelapseState = .standby
  }
  
  func recordSegment() {
    // there's a small delay between record request and record start. disable ui until then
    view.isUserInteractionEnabled = false
    NextLevel.shared.record()
    timelapseState = .activeInLoop
    // restart timing done in delegate method below
  }
  
  func flipCamera() {
    NextLevel.shared.flipCaptureDevicePosition()
  }
  
  public func reset() {
    resetTimer.invalidate()
    timelapseState = .standby
    configInfoVC.refresh()
    if let session = NextLevel.shared.session {
      session.removeAllClips()
    }
  }

  func showPreSaveAlert() {
    let alertController = UIAlertController(title: "Save video?", message: "You can either save the video now or record more.", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Not yet", style: .cancel))
    alertController.addAction(UIAlertAction(title: "Save", style: .default) { action in
      self.suspendTimelapse()
      self.delegate?.gotoPreview()
    })
    present(alertController, animated: true)
  }
}

extension RecordingViewController: NextLevelDelegate, NextLevelDeviceDelegate, NextLevelVideoDelegate {
  func nextLevel(_ nextLevel: NextLevel, didUpdateVideoConfiguration videoConfiguration: NextLevelVideoConfiguration) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didUpdateAudioConfiguration audioConfiguration: NextLevelAudioConfiguration) {
    
  }
  
  func nextLevelSessionWillStart(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelSessionDidStart(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelSessionDidStop(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelSessionWasInterrupted(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelSessionInterruptionEnded(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelCaptureModeWillChange(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelCaptureModeDidChange(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelDevicePositionWillChange(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelDevicePositionDidChange(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didChangeDeviceOrientation deviceOrientation: NextLevelDeviceOrientation) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didChangeDeviceFormat deviceFormat: AVCaptureDevice.Format) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didChangeCleanAperture cleanAperture: CGRect) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didChangeLensPosition lensPosition: Float) {
    
  }
  
  func nextLevelWillStartFocus(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelDidStopFocus(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelWillChangeExposure(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelDidChangeExposure(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelWillChangeWhiteBalance(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelDidChangeWhiteBalance(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didUpdateVideoZoomFactor videoZoomFactor: Float) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, willProcessRawVideoSampleBuffer sampleBuffer: CMSampleBuffer, onQueue queue: DispatchQueue) {
    guard Defaults.motionControlEnabled else { return }
    MotionHelper.sampleThrottleCounter += 1
    guard MotionHelper.sampleThrottleCounter % MotionHelper.ThrottleCycle == 0 else { return }
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        try imageRequestHandler.perform([self.motionHelper.contourRequest])
        DispatchQueue.main.async {
          self.configInfoVC.setMotionSense(self.motionHelper.motionSensed)
          if self.motionHelper.didSenseMotion, self.timelapseState == .idleInLoop {
            self.delayThenRecord()
          }
        }
      } catch {
        print(error)
      }
    }
  }
  
  func delayThenRecord() {
    timelapseState = .delayingInLoop
    clockOverlay.animateYellowCircle(duration: Defaults.delaySeconds)
    DispatchQueue.main.asyncAfter(deadline: .now() + Defaults.delaySeconds) {
      if self.timelapseState != .delayingInLoop {
        // Expect nothing else to change while delaying in loop. UI should be disabled.
        print("OOPS shouldn't be here!")
      }
      self.recordSegment()
    }
  }
  
  func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
    let context = CIContext(options: nil)
    if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
      return cgImage
    }
    return nil
  }
  
  
  func nextLevel(_ nextLevel: NextLevel, renderToCustomContextWithImageBuffer imageBuffer: CVPixelBuffer, onQueue queue: DispatchQueue) {

  }
  
  func nextLevel(_ nextLevel: NextLevel, willProcessFrame frame: AnyObject, timestamp: TimeInterval, onQueue queue: DispatchQueue) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didSetupVideoInSession session: NextLevelSession) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didSetupAudioInSession session: NextLevelSession) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didStartClipInSession session: NextLevelSession) {
    view.isUserInteractionEnabled = true
    let duration = TimeInterval(Defaults.durationControl)
    let interval = TimeInterval(Defaults.intervalControl)
    clockOverlay.animateRedCircle(duration: duration)
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
      NextLevel.shared.pause()
      self.timelapseState = .waitingInLoop
      self.clockOverlay.animateWhiteCircle(duration: interval)
    }
    
    let restartSecs = duration + interval
    resetTimer = Timer(timeInterval: restartSecs, repeats: false, block: { _ in
      guard self.timelapseState == .waitingInLoop else { return }
      if Defaults.motionControlEnabled {
        self.timelapseState = .idleInLoop
      } else {
        self.recordSegment()
      }
    })
    RunLoop.main.add(resetTimer, forMode: .common)
  }
  
  func nextLevel(_ nextLevel: NextLevel, didCompleteClip clip: NextLevelClip, inSession session: NextLevelSession) {

  }
  
  func nextLevel(_ nextLevel: NextLevel, didAppendVideoSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
  }
  
  func nextLevel(_ nextLevel: NextLevel, didSkipVideoSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
  }
  
  func nextLevel(_ nextLevel: NextLevel, didAppendVideoPixelBuffer pixelBuffer: CVPixelBuffer, timestamp: TimeInterval, inSession session: NextLevelSession) {
    print(" didAppendVideoPixelBuffer pixelBuffer??")

  }
  
  func nextLevel(_ nextLevel: NextLevel, didSkipVideoPixelBuffer pixelBuffer: CVPixelBuffer, timestamp: TimeInterval, inSession session: NextLevelSession) {
    print(" didSkipVideoPixelBuffer pixelBuffer??")
  }
  
  func nextLevel(_ nextLevel: NextLevel, didAppendAudioSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didSkipAudioSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didCompleteSession session: NextLevelSession) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didCompletePhotoCaptureFromVideoFrame photoDict: [String : Any]?) {
    
  }
  
}

extension RecordingViewController: ConfigViewControllerDelegate {
  func configVCDidChangeConfig() {
    renderTimelapseState()
    configInfoVC.refresh()
  }
}
