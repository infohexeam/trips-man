//
//  SuccessViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 27/06/23.
//

import UIKit

class SuccessViewController: UIViewController {
    
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successLabel: UILabel!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingText: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var paymentResponse: [AnyHashable: Any]?
    var bookingID = 0
    var listType: ListType?
    
    let parser = Parser()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        successView.isHidden = true
        
        if let paymentResponse = paymentResponse {
            verifyPayment(with: paymentResponse)
        }
    }
    

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.navigationController?.isNavigationBarHidden = false
    }
    
    func showLoading(with text: String) {
        loadingText.text = text
        loadingIndicator.startAnimating()
        loadingView.isHidden = false
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
        loadingView.isHidden = true
    }
    
    @IBAction func returnHomeButton(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }

}


//MARK: - APICalls
extension SuccessViewController {
    
    func verifyPayment(with paymentResponse: [AnyHashable: Any]) {
        showLoading(with: K.paymentVerifyingMessage)
        let params: [String: Any] = ["orderId": paymentResponse["razorpay_order_id"] ?? "",
                                     "paymentId": paymentResponse["razorpay_payment_id"] ?? "",
                                     "signature": paymentResponse["razorpay_signature"] ?? ""]
        
        parser.sendRequestLoggedIn(url: "api/Payment/VerifyPayment", http: .post, parameters: params) { (result: BasicResponse?, error) in
            DispatchQueue.main.async {
                self.hideLoading()
                if error == nil {
                    if result!.status == 1 {
                        self.confirmBooking()
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
                    
            }
        }
    }
    
    
    func confirmBooking() {
        showLoading(with: K.confirmBookingmMessage)
        var url = ""
        if let listType = listType {
            switch listType {
            case .hotel:
                url = "api/CustomerHotelBooking/ConfirmCustomerHotelBooking?BookingId=\(bookingID)"
            case .packages:
                url = "api/CustomerHoliday/ConfirmCustomerHolidayBooking?BookingId=\(bookingID)"
            case .activities:
                url = "api/CustomerActivity/ConfirmCustomerActivityBooking?BookingId=\(bookingID)"
            case .meetups:
                url = "api/CustomerMeetup/ConfirmCustomerMeetupBooking?BookingId=\(bookingID)"
            }
        }
        
        parser.sendRequestLoggedIn(url: url, http: .post, parameters: nil) { (result: ConfirmBookingData?, error) in
            DispatchQueue.main.async {
                self.hideLoading()
                if error == nil {
                    if result!.status == 1 {
                        self.successView.isHidden = false
                        self.successLabel.text = K.getBookingSuccessMessage(for: result!.data.module, with: result!.data.bookingNo)
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
                    
            }
        }
    }
}
