// https://gist.github.com/jdev7/40b1416d70766f7b38b92d3c9eae985c
import UIKit

public class CircleView: UIView {
  private var radius: CGFloat { (bounds.height - lineWidth) / 2 }
  private let baseLayer = CAShapeLayer()
  private let progressLayer = CAShapeLayer()
  private let progress: CGFloat
  private let lineWidth: CGFloat = 10.0
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  public init(progress: CGFloat, baseColor: UIColor, progressColor: UIColor) {
    self.progress = progress
    
    for layer in [baseLayer, progressLayer] {
      layer.fillColor = UIColor.clear.cgColor
      layer.lineWidth = lineWidth
      layer.lineCap = .butt
    }
    baseLayer.strokeColor = baseColor.cgColor
    baseLayer.strokeEnd = 1.0
    
    progressLayer.strokeColor = progressColor.cgColor
    progressLayer.strokeEnd = 0.0
    
    super.init(frame: .zero)
    
    layer.addSublayer(baseLayer)
    layer.addSublayer(progressLayer)
  }
  
  public func animateCircle(duration: TimeInterval, delay: TimeInterval) {
    progressLayer.removeAnimation(forKey: "circleAnimation")
    progressLayer.strokeEnd = 0
    addAnimation(duration: duration, delay: delay)
  }
  
  override open func layoutSubviews() {
    super.layoutSubviews()
    baseLayer.frame = bounds
    progressLayer.frame = bounds
    
    let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    let basePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: .initialAngle, endAngle: .endAngle(progress: 1), clockwise: true)
    let progressPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: .initialAngle, endAngle: .endAngle(progress: progress), clockwise: true)
    baseLayer.path = basePath.cgPath
    progressLayer.path = progressPath.cgPath
  }
  
  public func cancelAnimations() {
    progressLayer.removeAllAnimations()
  }
}

private extension CircleView {
  func addAnimation(duration: TimeInterval, delay: TimeInterval) {
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    animation.beginTime = CACurrentMediaTime() + delay
    animation.duration = duration
    animation.fromValue = 0
    animation.toValue = 1
    animation.timingFunction = CAMediaTimingFunction(name: .linear)
    animation.fillMode = .forwards
    animation.isRemovedOnCompletion = false
    progressLayer.add(animation, forKey: "circleAnimation")
  }
}

private extension CGFloat {
  static var initialAngle: CGFloat = -(.pi / 2)
  
  static func endAngle(progress: CGFloat) -> CGFloat {
    .pi * 2 * progress + .initialAngle
  }
}

