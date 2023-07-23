//
//  UILabel+Extension.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 25/10/22.
//

import Foundation
import UIKit

//var fontSize: CGFloat? = nil

extension UILabel {
    func addPriceString(_ price: Double,_ offerPrice: Double, fontSize: CGFloat, twoLine: Bool = false)  {
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: "\(price.attachCurrency)")
        
//        if fontSize == nil {
//            fontSize = self.font.pointSize
//        }
        
        if (offerPrice > 0) {
            let priceTextAttribute = [NSAttributedString.Key.font: UIFont(name: "Roboto-Regular", size: fontSize - 4)]
            
            attributeString.addAttributes(priceTextAttribute as [NSAttributedString.Key : Any], range: NSRange(location: SessionManager.shared.getCurrency().count - 1, length: price.stringValue().count))
            let currencyAttribute = [NSAttributedString.Key.font: UIFont(name: "Roboto-Regular", size: fontSize - 4)]
            attributeString.addAttributes(currencyAttribute as [NSAttributedString.Key : Any], range: NSRange(location: 0, length: SessionManager.shared.getCurrency().count))
            attributeString.addAttribute(.strikethroughStyle, value: 1, range: NSRange(location: 0, length: attributeString.length))
            attributeString.addAttribute(.foregroundColor, value: UIColor(named: "tertiaryLabel") ?? .lightGray, range: NSRange(location: 0, length: attributeString.length))
            let offerString = NSMutableAttributedString(string: "\(offerPrice.attachCurrency)")
            let offerCurrencyAttribute = [NSAttributedString.Key.font: UIFont(name: self.font!.fontName, size: fontSize - 4)]
            offerString.addAttributes(offerCurrencyAttribute as [NSAttributedString.Key : Any], range: NSRange(location: 0, length: SessionManager.shared.getCurrency().count))
            let finalString: NSMutableAttributedString = attributeString.mutableCopy() as! NSMutableAttributedString
//            if twoLine {
//                finalString.append(NSAttributedString(string: "\n"))
//            } else {
                finalString.append(NSAttributedString(string: " "))
//            }
            finalString.append(offerString)
            self.attributedText = finalString
            
        } else {
            let currencyAttribute = [NSAttributedString.Key.font: UIFont(name: self.font!.fontName, size: fontSize - 4)]
            attributeString.addAttributes(currencyAttribute as [NSAttributedString.Key : Any], range: NSRange(location: 0, length: SessionManager.shared.getCurrency().count))
            
            self.attributedText = attributeString
        }
    }
    
    
    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
        
        let readMoreText: String = trailingText + moreText
        
        if self.visibleTextLength == 0 { return }
        
        let lengthForVisibleString: Int = self.visibleTextLength
        
        if let myText = self.text {
            
            let mutableString: String = myText
            
            let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: myText.count - lengthForVisibleString), with: "")
            
            let readMoreLength: Int = (readMoreText.count)
            
            guard let safeTrimmedString = trimmedString else { return }
            
            if safeTrimmedString.count <= readMoreLength { return }
            
            print("this number \(safeTrimmedString.count) should never be less\n")
            print("then this number \(readMoreLength)")
            
            // "safeTrimmedString.count - readMoreLength" should never be less then the readMoreLength because it'll be a negative value and will crash
            let trimmedForReadMore: String = (safeTrimmedString as NSString).replacingCharacters(in: NSRange(location: safeTrimmedString.count - readMoreLength, length: readMoreLength), with: "") + trailingText
            
            let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedString.Key.font: self.font!])
            let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.foregroundColor: moreTextColor])
            answerAttributed.append(readMoreAttributed)
            self.attributedText = answerAttributed
        }
    }
    
    var visibleTextLength: Int {
        
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        if let myText = self.text {
            
            let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
            let attributedText = NSAttributedString(string: myText, attributes: attributes as? [NSAttributedString.Key : Any])
            let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
            
            if boundingRect.size.height > labelHeight {
                var index: Int = 0
                var prev: Int = 0
                let characterSet = CharacterSet.whitespacesAndNewlines
                repeat {
                    prev = index
                    if mode == NSLineBreakMode.byCharWrapping {
                        index += 1
                    } else {
                        index = (myText as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: myText.count - index - 1)).location
                    }
                } while index != NSNotFound && index < myText.count && (myText as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key : Any], context: nil).size.height <= labelHeight
                return prev
            }
        }
        
        if self.text == nil {
            return 0
        } else {
            return self.text!.count
        }
    }
    
    func lines() -> Int {
        let textSize = CGSize(width: self.frame.size.width, height: CGFloat(Float.infinity))
        let rHeight = lroundf(Float(self.sizeThatFits(textSize).height))
        let charSize = lroundf(Float(self.font.lineHeight))
        let lineCount = rHeight/charSize
        return lineCount
    }
}


