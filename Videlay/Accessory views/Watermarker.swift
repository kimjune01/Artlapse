//
//  Watermarker.swift
//  Videlay
//
//  Created by June Kim on 5/19/24.
//

import Foundation
import MediaWatermark

class Watermarker {
  static func watermark(video url: URL, completion: @escaping (_: URL?, _:Error?) -> ()) {
    guard let item = MediaItem(url: url) else { return }
    let logoImage = UIImage(named: "AppIcon")
    
    let firstElement = MediaElement(image: logoImage!)
    firstElement.frame = CGRect(x: 0, y: 0, width: logoImage!.size.width, height: logoImage!.size.height)
    
    let testStr = "Attributed Text"
    let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                      NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35) ]
    let attrStr = NSAttributedString(string: testStr, attributes: attributes)
    
    let secondElement = MediaElement(text: attrStr)
    secondElement.frame = CGRect(x: 300, y: 300, width: logoImage!.size.width, height: logoImage!.size.height)
    
    item.add(elements: [firstElement, secondElement])
    
    let mediaProcessor = MediaProcessor()
    mediaProcessor.processElements(item: item) { (result, error) in
      completion(result.processedUrl, error)
    }
  }
}
