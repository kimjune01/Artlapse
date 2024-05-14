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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    addPlayer()
    preparePreview()
//    export()
    addActionButton()
  }
  
  func preparePreview() {
    guard let session = NextLevel.shared.session else {
      return
    }
    session.mergeClips(usingPreset: AVAssetExportPresetHighestQuality, completionHandler: { (url: URL?, error: Error?) in
      if let url = url {
        self.assetUrl = url
        self.player.url = url
      } else if let _ = error {
        self.showExportAlert()
      }
    })
  }
  
  func export() {
    guard let url = assetUrl else {
      assert(false)
      return
    }
    saveVideoToAlbum(url) { [weak self] err in
      guard let self = self else { return }
      guard err == nil else {
        self.showExportAlert()
        return
      }
      self.showPostSaveAlert()
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
  
  func showExportAlert() {
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
    player.playbackFreezesAtEnd = false
    player.playbackLoops = true
    player.view.frame = view.bounds
    player.view.backgroundColor = .lightGray
    view.addSubview(player.view)
    let playerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedPlayer))
    player.view.addGestureRecognizer(playerTapRecognizer)

  }
  
  func addActionButton() {
    view.addSubview(actionButton)
    actionButton.fillBottomOfParent(height: UIButton.actionButtonHeight, insideSafeArea: true)
    actionButton.tintColor = .white
    actionButton.backgroundColor = .systemBlue
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
    guard let url = player.url else {
      alert("Exported file missing.")
      return
    }
    requestPhotoLibraryAuthorization {
      self.saveVideoToPhotosAlbum(url) { saved in
        if saved {
          self.showSavedSuccessAlert()
        } else {
          self.showNotSavedAlert()
        }
      }
    }
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
