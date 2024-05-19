//
//  PreferenceRow.swift
//  Videlay
//
//  Created by June Kim on 5/19/24.
//

import UIKit

class PreferenceRow: UIStackView {
  private let label = UILabel()

  init(labelText: String) {
    super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 10, height: 45))
    axis = .horizontal
    alignment = .center
    distribution = .equalSpacing
    set(width: UIScreen.main.bounds.width - 10)
    set(height: 45)
    
    addArrangedSubview(label)
    label.pinLeadingToParent(margin: 8)
    label.text = labelText
    label.font = .systemFont(ofSize: 16)
    label.textColor = .black
    label.textAlignment = .left
    label.numberOfLines = 0

    let padding = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    addArrangedSubview(padding)
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
