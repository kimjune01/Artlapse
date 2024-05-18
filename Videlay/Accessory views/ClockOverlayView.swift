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
  private let yellowCircle = CircleView(progress: 1, baseColor: .clear, progressColor: .yellow.withAlphaComponent(0.3))
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
    let redSmallerBy: CGFloat = 0.9
    redCircle.frame = CGRect(x: ClockOverlayView.outerDiameter * (1 - redSmallerBy) / 2,
                             y: ClockOverlayView.outerDiameter * (1 - redSmallerBy) / 2,
                               width: ClockOverlayView.outerDiameter * redSmallerBy,
                               height: ClockOverlayView.outerDiameter * redSmallerBy)
    
    let yellowSmallerBy: CGFloat = 0.8
    yellowCircle.frame =  CGRect(x: ClockOverlayView.outerDiameter * (1 - yellowSmallerBy) / 2,
                                 y: ClockOverlayView.outerDiameter * (1 - yellowSmallerBy) / 2,
                                 width: ClockOverlayView.outerDiameter * yellowSmallerBy,
                                 height: ClockOverlayView.outerDiameter * yellowSmallerBy)
    
    addSubview(whiteCircle)
    addSubview(redCircle)
    addSubview(yellowCircle)

  }
  
  func animateWhiteCircle(duration: CGFloat) {
    cancelAnimations()
    whiteCircle.animateCircle(duration: duration, delay: 0)
  }

  func animateRedCircle(duration: CGFloat) {
    cancelAnimations()
    redCircle.animateCircle(duration: duration, delay: 0)
  }
  
  func animateYellowCircle(duration: CGFloat) {
    cancelAnimations()
    yellowCircle.animateCircle(duration: duration, delay: 0)
  }
  
  func cancelAnimations() {
    redCircle.cancelAnimations()
    whiteCircle.cancelAnimations()
    yellowCircle.cancelAnimations()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
}
