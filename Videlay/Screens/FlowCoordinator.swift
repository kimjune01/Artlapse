//
//  FlowCoordinator.swift
//  Videlay
//
//  Created by June Kim on 5/14/24.
//

import Foundation
import UIKit

class FlowCoordinator: NSObject, UINavigationControllerDelegate {
  var navController: UINavigationController!
  
  override init() {
    super.init()
    
  }
  
  func rootNavViewController() -> UIViewController {
    let mainVC = RecordingViewController()
    mainVC.delegate = self
    navController = UINavigationController(rootViewController: mainVC)
    navController.delegate = self
    let titleDict: NSDictionary = [NSAttributedString.Key.foregroundColor: UIColor.white]
    navController.navigationBar.titleTextAttributes = titleDict as? [NSAttributedString.Key : Any]
    navController.navigationBar.tintColor = .white
    return navController
  }
  
}

extension FlowCoordinator: RecordingViewControllerDelegate {
  
  func gotoPreview() {
    let exportPreviewVC = ExportPreviewViewController()
    exportPreviewVC.delegate = self
    navController.pushViewController(exportPreviewVC, animated: true)

  }
}

extension FlowCoordinator: ExportPreviewViewControllerDelegate {
  func exportPreviewVCDidFinish(_ previewVC: ExportPreviewViewController) {
    navController.popToRootViewController(animated: true)
    if let recVC = navController.topViewController as? RecordingViewController {
      recVC.reset()
    }
  }
}
