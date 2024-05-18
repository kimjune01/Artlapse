//
//  ExportPreviewViewController.swift
//  Sequence
//
//  Created by June Kim on 9/25/21.
//

import UIKit
import MediaPlayer
import MobileCoreServices
import Photos
import Player
import Social
import NextLevel

enum ExportPreviewViewControllerState {
  case initial
  case playing
  case paused
}

protocol ExportPreviewViewControllerDelegate: AnyObject {
  func exportPreviewVCDidFinish(_ previewVC: ExportPreviewViewController)
}

// instantiate a new export preview with each session. Does not edit sequence.
class ExportPreviewViewController: UIViewController {
  weak var delegate: ExportPreviewViewControllerDelegate?
  var state: ExportPreviewViewControllerState = .initial
  let player = Player()
  let actionButton = UIButton()
  let backButton = UIButton.backButton()
  var assetUrl: URL?
  var playbackCounter = 0
  let backgroundPlaceholder = UIImageView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .darkGray
    addPlayer()
    addBackgroundPlaceholder()
    addActionButton()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    preparePreview()

  }
  func preparePreview() {
    playerPlaybackDidEnd(player)
  }
  
  func addBackgroundPlaceholder() {
    guard let session = NextLevel.shared.session,
          let firstClip = session.clips.first else {
      return
    }
    
    backgroundPlaceholder.image = firstClip.lastFrameImage
    view.insertSubview(backgroundPlaceholder, belowSubview: player.view)
    backgroundPlaceholder.frame = player.view.frame
    backgroundPlaceholder.contentMode = .scaleAspectFit
  }
  
  func export() {
    guard let session = NextLevel.shared.session else {
      assert(false)
      return
    }
    
    actionButton.isEnabled = false

    session.mergeClips(usingPreset: AVAssetExportPresetHighestQuality) { url, err in
      guard let url = url, err == nil else {
        self.showExportFailAlert()
        self.actionButton.isEnabled = true
        return
      }
      self.saveVideoToPhotosAlbum(url) { saved in
        DispatchQueue.main.async {
          if saved {
            self.showSavedSuccessAlert()
          } else {
            self.showNotSavedAlert()
          }
          self.actionButton.isEnabled = true
        }
      }
    }
  }
  
  func saveVideoToAlbum(_ outputURL: URL, _ completion: @escaping (Error?) -> ()) {
    PHPhotoLibrary.shared().performChanges({
      let request = PHAssetCreationRequest.forAsset()
      request.addResource(with: .video, fileURL: outputURL, options: nil)
    }) { (result, error) in
      DispatchQueue.main.async {
        if let error = error {
          print(error.localizedDescription)
        }
        completion(error)
      }
    }
  }
  
  func showExportFailAlert() {
    let alertController = UIAlertController(title: "Export failed", message: "I'm not quite sure why but it didn't work for some reason. Maybe you can tell me in the chat?", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
//      self.reset()
    }))
    present(alertController, animated: true)
  }
  
  func showPostSaveAlert() {
    let alertController = UIAlertController(title: "Video saved", message: "Go to your photos app to watch the video", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
    present(alertController, animated: true)
  }
  
  func addPlayer() {
    player.playbackPausesWhenBackgrounded = true
    player.playbackPausesWhenResigningActive = true
    player.playbackFreezesAtEnd = true
    player.view.frame = view.bounds
    view.addSubview(player.view)
    let playerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedPlayer))
    player.view.addGestureRecognizer(playerTapRecognizer)
    player.playbackDelegate = self
  }
  
  func addActionButton() {
    view.addSubview(actionButton)
    actionButton.centerXInParent()
    actionButton.pinBottomToParent(margin: 12, insideSafeArea: true)
    actionButton.tintColor = .white
    actionButton.roundCorner(radius: 8)
    actionButton.setImage(UIImage(named: "photos-app-icon"), for: .normal)
    actionButton.addTarget(self, action: #selector(tappedSaveButton), for: .touchUpInside)
  }
  
  @objc func tappedPlayer() {
    guard player.url != nil else { return }
    if player.isPlayingVideo {
      player.pause()
      state = .paused
    } else {
      state = .playing
      player.playFromCurrentTime()
    }
  }
  
  @objc func tappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
  func requestPhotoLibraryAuthorization(_ completion: @escaping Completion) {
    // Ensure permission to access Photo Library
    if PHPhotoLibrary.authorizationStatus() != .authorized {
      PHPhotoLibrary.requestAuthorization { status in
        if status == .authorized {
          completion()
        }
      }
    } else {
      completion()
    }
  }

  func saveVideoToPhotosAlbum(_ url: URL, _ completion: @escaping BoolCompletion) {
    let changes: () -> Void = {
      PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
    }
    PHPhotoLibrary.shared().performChanges(changes) { saved, error in
      DispatchQueue.main.async {
        completion(saved)
      }
    }
  }
  
  func savedPhotosAvailable() -> Bool {
    guard !UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
    else { return true }
    
    let alert = UIAlertController(
      title: "Not Available",
      message: "No Saved Album found",
      preferredStyle: .alert)
    alert.addAction(UIAlertAction(
      title: "OK",
      style: UIAlertAction.Style.cancel,
      handler: { action in
        
      }))
    present(alert, animated: true, completion: nil)
    return false
  }
  
  @objc func tappedSaveButton() {
    showSaveWillEndSessionAlert(accept: {
      self.requestPhotoLibraryAuthorization {
        self.export()
      }
    })
  }
  
  func showSaveWillEndSessionAlert(accept: @escaping () -> ()) {
    let alertController = UIAlertController(title: "Save video?", message: "If you save the video now, you will not be able to append more clips to this video. You will start a new session.", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Not yet", style: .cancel))
    alertController.addAction(UIAlertAction(title: "Save", style: .default) { action in
      accept()
    })
    present(alertController, animated: true)
  }
  
  func showSavedSuccessAlert() {
    let title = "Success"
    let message = "Video saved in your photos album"
    
    let alert = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert)
    alert.addAction(UIAlertAction(
      title: "OK",
      style: UIAlertAction.Style.cancel,
      handler: { action in
        self.delegate?.exportPreviewVCDidFinish(self)
      }))
//    alert.addAction(UIAlertAction(
//      title: "Share",
//      style: UIAlertAction.Style.default,
//      handler: { action in
//        self.showShareSheet()
//      }))
    self.present(alert, animated: true, completion: nil)
  }
  
  func showNotSavedAlert() {
    let title = "Error"
    let message = "Failed to save video. Try again?"
    
    let alert = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert)
    alert.addAction(UIAlertAction(
      title: "OK",
      style: UIAlertAction.Style.cancel,
      handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
  func showShareSheet() {
    let shareSheet = SLComposeViewController()
    
    present(shareSheet, animated: true, completion: nil)
  }

}

extension ExportPreviewViewController: PlayerPlaybackDelegate {
  func playerCurrentTimeDidChange(_ player: Player) {
    
  }
  
  func playerPlaybackWillStartFromBeginning(_ player: Player) {
    
  }
  
  func playerPlaybackWillLoop(_ player: Player) {
    
  }
  
  func playerPlaybackDidLoop(_ player: Player) {
    
  }
  
  func playerPlaybackDidEnd(_ player: Player) {
    guard let session = NextLevel.shared.session else {
      return
    }
    let clipsCount = session.clips.count
    guard clipsCount > 0 else { return }
    let nextClip = session.clips[playbackCounter % clipsCount]
    guard let url = nextClip.url else {
      return
    }
    player.url = url
    backgroundPlaceholder.image = nextClip.lastFrameImage

    player.playFromBeginning()
    playbackCounter += 1
  }
}
