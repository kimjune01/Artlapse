//
//  ClockOverlayView.swift
//  Videlay
//
//  Created by June Kim on 10/9/22.
//

import UIKit

// shows a percentage of a stroked circle
class ClockOverlayView: UIView {
  
  private let whiteCircle = CircleView(progress: 1, baseColor: .clear, progressColor: .white.withAlphaComponent(0.3))
  private let redCircle = CircleView(progress: 1, baseColor: .clear, progressColor: .red.withAlphaComponent(0.7))
  
  // assume portrait only.
  static let outerDiameter = UIScreen.main.bounds.width * 0.8
  
  private var startTime = 0.0
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
    addCircles()
  }
  
  
  func addCircles() {
    whiteCircle.frame = CGRect(x: 0, y: 0,
                               width: ClockOverlayView.outerDiameter,
                               height: ClockOverlayView.outerDiameter)
    let smallerBy: CGFloat = 0.9
    redCircle.frame = CGRect(x: ClockOverlayView.outerDiameter * (1 - smallerBy) / 2,
                             y: ClockOverlayView.outerDiameter * (1 - smallerBy) / 2,
                               width: ClockOverlayView.outerDiameter * smallerBy,
                               height: ClockOverlayView.outerDiameter * smallerBy)
    
    addSubview(whiteCircle)
    addSubview(redCircle)

  }
  
  func animateWhiteCircle(duration: CGFloat) {
    redCircle.cancelAnimations()
    whiteCircle.animateCircle(duration: duration, delay: 0)
  }

  func animateRedCircle(duration: CGFloat) {
    whiteCircle.cancelAnimations()
    redCircle.animateCircle(duration: duration, delay: 0)
  }
  
  func cancelAnimations() {
    redCircle.cancelAnimations()
    whiteCircle.cancelAnimations()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
}
