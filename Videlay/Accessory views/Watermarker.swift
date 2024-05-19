//
//  Watermarker.swift
//  Videlay
//
//  Created by June Kim on 5/19/24.
//

import Foundation
import MediaWatermark

enum WatermarkError: Error {
  case MediaItemCannotBeCreated
}

class Watermarker {
  static func watermark(video url: URL, completion: @escaping (_: URL?, _:Error?) -> ()) {
    guard Defaults.watermarkPreference else { completion(url, nil); return }
    guard let item = MediaItem(url: url) else { completion(nil, WatermarkError.MediaItemCannotBeCreated); return }
    
    let testStr = "recorded with Artlapse"
    let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.4),
                      NSAttributedString.Key.font: UIFont.monospacedSystemFont(ofSize: 55, weight: .medium) ]
    let attrStr = NSAttributedString(string: testStr, attributes: attributes)
    
    let secondElement = MediaElement(text: attrStr)
    secondElement.frame = CGRect(x: 10, y: 10, width: 1000, height: 100)
    
    item.add(elements: [secondElement])
    
    let mediaProcessor = MediaProcessor()
    mediaProcessor.processElements(item: item) { (result, error) in
      completion(result.processedUrl, error)
    }
  }
}
