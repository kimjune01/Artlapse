//
//  RecordButton.swift
//  Videlay
//
//  Created by June Kim on 10/9/22.
//

import UIKit

class RecordButton: UIView {
  let defaultSize: CGFloat = 75
  
  override init(frame: CGRect) {
    super.init(frame: CGRect(x: frame.minX, y: frame.minY, width: defaultSize, height: defaultSize))
    turnToRoundedRect()
  }
  
  func turnToCircle() {
    layer.cornerRadius = defaultSize / 2
    layer.cornerCurve = .circular
  }
  
  func turnToRoundedRect() {
    layer.cornerRadius = defaultSize / 4
    layer.cornerCurve = .continuous
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
