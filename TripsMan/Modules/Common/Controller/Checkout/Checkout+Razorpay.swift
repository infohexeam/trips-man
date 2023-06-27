//
//  Checkout+Razorpay.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 27/06/23.
//

import Foundation
import Razorpay

extension CheckoutViewController: RazorpayPaymentCompletionProtocolWithData {
    
    
    
    func openRazorPay(with paymentId: String) {
        razorpay = RazorpayCheckout.initWithKey(K.razorpayKey, andDelegateWithData: self)
        
        let options: [String:Any] = [
            "currency": SessionManager.shared.getCurrency(),
            "order_id": paymentId,
            "theme": [
                "color": "#F6A100"
            ]
        ]
        razorpay.open(options)
    }
    
    
//    "amount": "100", //This is in currency subunits. 100 = 100 paise= INR 1.
//                    "currency": "INR",//We support more that 92 international currencies.
//                    "description": "purchase description",
//                    "order_id": "order_DBJOWzybf0sJbb",
//                    "image": "https://url-to-image.jpg",
//                    "name": "business or product name",
//                    "prefill": [
//                        "contact": "9797979797",
//                        "email": "foo@bar.com"
//                    ],
//                    "theme": [
//                        "color": "#F37254"
//                    ]
  
    
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]?) {
        print("\nPaymentError: \(code) \(str)")
    }
    
    func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]?) {
        if let response = response {
            performSegue(withIdentifier: "toSuccess", sender: response)
        }
    }
    
    
}
