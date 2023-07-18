//
//  String+Extension.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 09/01/23.
//

import Foundation
import SDWebImage

extension String {
    func intValue() -> Int {
        return Int(self) ?? 0
    }
    
    var capitalizedSentence: String {
            let firstLetter = self.prefix(1).capitalized
            let remainingLetters = self.dropFirst().lowercased()
            return firstLetter + remainingLetters
        }
    
    func loadImage(completion: @escaping (UIImage) -> Void) {
        SDWebImageManager.shared.loadImage(
            with: URL(string: self),
            options: [.highPriority, .progressiveLoad],
            progress: { (receivedSize, expectedSize, url) in
                //Progress tracking code
            },
            completed: { (image, data, error, cacheType, finished, url) in
//                guard self != nil else { return }
                guard error == nil else { return }
                if let image = image {
                    completion(image)
                }
            }
        )
        
    }
    
    func localized() -> String {
        return NSLocalizedString(self, tableName: "localizable", comment: "")
    }
}


//MARK: - HTML
extension String {
    
    var utfData: Data {
        return Data(utf8)
    }
    
    var attributedHtmlString: NSAttributedString? {
        
        do {
            return try NSAttributedString(data: utfData, options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
                                          documentAttributes: nil)
        } catch {
            print("Error:", error)
            return nil
        }
    }
}

extension UILabel {
    func setAttributedHtmlText(_ html: String) {
        if let attributedText = html.attributedHtmlString {
            self.attributedText = attributedText
      }
   }
}

