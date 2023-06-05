//
//  Double+Extension.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 19/01/23.
//

import Foundation

extension Double {
    
    var clean: String {
           return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
    
    func stringValue() -> String {
        return "\(self)"
    }
    
    var rounded: String {
        let divisor = pow(10.0, Double(1))
        
        let numb = (self * divisor).rounded() / divisor
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        
        return formatter.string(from: numb as NSNumber) ?? ""
        
    }
}

//Percentage
extension Double {
    func percentage(_ total: Double) -> String {
        let val = (self/total)*100
        return "\(val.clean)"
    }
}

extension Int {
    func oneOrMany(_ word: String, suffix: String = "s") -> String {
            if self == 1 {
                return "\(self) \(word)"
            } else {
                return "\(self) \(word)\(suffix)"
            }
    }
    
    func stringValue() -> String {
        return "\(self)"
    }
    
    func pageCount(with recordCount: Int) -> Int {
        return Int(ceil(Double(self)/Double(recordCount)))
    }
}
