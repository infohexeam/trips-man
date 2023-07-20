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
    @IBOutlet weak var successIcon: UIImageView!
    @IBOutlet weak var successTitle: UILabel!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingText: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    
    
    var paymentResponse: [AnyHashable: Any]?
    var bookingID = 0
    var listType: ListType?
    
    let parser = Parser()
    
    var successStaus: SuccessStatus!
    
    struct SuccessStatus {
        var verifyPayment: Bool = false
        var confirmBooking: Bool = false
    }
    
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
        
        successStaus = SuccessStatus(verifyPayment: false, confirmBooking: false)
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
    
    func showSuccessView(for module: String?, with bookingNo: String?) {
        
        if successStaus.verifyPayment == true && successStaus.confirmBooking == true {
            self.successIcon.image = UIImage(named: "success-check")
            self.successTitle.text = "Congratulations!".localized()
            self.successLabel.text = K.getBookingSuccessMessage(for: module!, with: bookingNo!)
        } else if successStaus.verifyPayment == false && successStaus.confirmBooking == true {
            self.successIcon.image = UIImage(named: "yellow-checkmark")
            self.successTitle.text = "Booking Success & Awaiting Payment".localized()
            self.successLabel.text = K.getPaymentWaitingMessage(for: module!, with: bookingNo!)
        } else if successStaus.confirmBooking == false { //payment verification success or failure
            self.successIcon.image = UIImage(named: "warning")
            self.successTitle.text = "Booking Not Confirmed".localized()
            self.successLabel.text = K.getBookingFailedMessage()
        }
        self.successView.isHidden = false
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
                                     "signature": paymentResponse["razorpay_signature"] ?? "",
                                     "moduleCode": K.getModuleCode(of: listType ?? .hotel),
                                     "bookingId": bookingID]
        
        parser.sendRequestLoggedIn(url: "api/Payment/VerifyPayment", http: .post, parameters: params) { (result: BasicResponse?, error) in
            DispatchQueue.main.async {
                self.hideLoading()
                if error == nil {
                    if result!.status == 1 {
                        self.successStaus.verifyPayment = true
                        self.confirmBooking()
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast(K.apiErrorMessage)
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
                        self.successStaus.confirmBooking = true
                        self.showSuccessView(for: result!.data.module, with: result!.data.bookingNo)
                    } else {
                        self.view.makeToast(result!.message)
                        self.showSuccessView(for: nil, with: nil)
                    }
                } else {
                    self.showSuccessView(for: nil, with: nil)
                }
            }
        }
    }
}
