//
//  AddReviewViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 02/03/23.
//

import UIKit
import Cosmos

class AddReviewViewController: UIViewController {
    
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var reviewText: UITextView!
    
    var tripDetails: HotelTripDetails?
    var reviewDelegate: AddReviewDelegate?
    
    let parser = Parser()
    let reviewManager = ReviewManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardOnTap()
        if reviewManager.isEdit(tripDetails) {
            self.title = "Edit Review"
            
            if let tripDetails = tripDetails {
                rating.rating = tripDetails.rating ?? 0
                titleField.text = tripDetails.reviewTitle
                reviewText.text = tripDetails.review
            }
            
        } else {
            self.title = "Add Review"
        }
    }
}

//MARK: - IBActions
extension AddReviewViewController {
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        let (valid, message) = reviewManager.isReviewValid(review: ReviewManager.Review(rating: rating.rating, reviewTitle: titleField.text, reviewText: reviewText.text))
        if valid {
            if reviewManager.isEdit(tripDetails) {
                updateReview()
            } else {
                submitReview()
            }
        } else {
            self.view.makeToast(message)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
}


//MARK: - APICalls
extension AddReviewViewController {
    
    func submitReview() {
        
        showIndicator()
        
        let params: [String: Any] = ["bookingId": tripDetails!.bookingID,
                                     "hotelId": tripDetails!.hotelID,
                                     "rating": rating.rating,
                                     "title": titleField.text ?? "",
                                     "review": reviewText.text ?? "",
                                     "userId": SessionManager.shared.getLoginDetails()?.userid ?? "",
                                     "language": SessionManager.shared.getLanguage().code]
        parser.sendRequestLoggedIn(url: "api/CustomerHotelBooking/AddReviewCustomerHotelBooking", http: .post, parameters: params) { (result: BasicResponse?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.reviewDelegate?.refreshReview()
                        self.dismiss(animated: true)
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
                    
            }
        }
    }
    
    func updateReview() {
        
        showIndicator()
        let params: [String: Any] = ["ReviewId": tripDetails!.reviewId!,
                                     "bookingId": tripDetails!.bookingID,
                                     "hotelId": tripDetails!.hotelID,
                                     "rating": rating.rating,
                                     "title": titleField.text ?? "",
                                     "review": reviewText.text ?? "",
                                     "userId": SessionManager.shared.getLoginDetails()?.userid ?? "",
                                     "language": SessionManager.shared.getLanguage().code]
        parser.sendRequestLoggedIn(url: "api/CustomerHotelBooking/UpdateReviewCustomerHotelBooking", http: .post, parameters: params) { (result: BasicResponse?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.reviewDelegate?.refreshReview()
                        self.dismiss(animated: true)
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
