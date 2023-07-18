//
//  Bundle+Extension.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 18/07/23.
//

import Foundation

extension Bundle {
    static func swizzleLocalization() {
            let orginalSelector = #selector(localizedString(forKey:value:table:))
            guard let orginalMethod = class_getInstanceMethod(self, orginalSelector) else { return }

            let mySelector = #selector(myLocaLizedString(forKey:value:table:))
            guard let myMethod = class_getInstanceMethod(self, mySelector) else { return }

            if class_addMethod(self, orginalSelector, method_getImplementation(myMethod), method_getTypeEncoding(myMethod)) {
                class_replaceMethod(self, mySelector, method_getImplementation(orginalMethod), method_getTypeEncoding(orginalMethod))
            } else {
                method_exchangeImplementations(orginalMethod, myMethod)
            }
    }

    @objc private func myLocaLizedString(forKey key: String,value: String?, table: String?) -> String {
        guard let bundlePath = Bundle.main.path(forResource: SessionManager.shared.getLanguage().code, ofType: "lproj"),
            let bundle = Bundle(path: bundlePath) else {
                return Bundle.main.myLocaLizedString(forKey: key, value: value, table: table)
        }
        return bundle.myLocaLizedString(forKey: key, value: value, table: table)
    }
}
