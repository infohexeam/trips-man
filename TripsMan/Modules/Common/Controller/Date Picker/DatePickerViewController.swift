//
//  DatePickerViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 15/03/23.
//

import UIKit

class DatePickerViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var hotelFilters = HotelListingFilters()
    var packageFilters = PackageFilters()
    var pickerTag = 0
    var minDate: Date?
    var maxDate: Date?
    var delegate: DatePickerDelegate?
    var viewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.tag = pickerTag
        datePicker.minimumDate = minDate

    }
    
    
    @IBAction func datePickerDoneTapped(_ sender: UIBarButtonItem) {
        delegate?.datePickerDoneTapped(viewController, date: datePicker.date, tag: pickerTag)
        self.dismiss(animated: true)
    }
}


protocol DatePickerDelegate {
    func datePickerDoneTapped(_ viewController: UIViewController?, date: Date, tag: Int)
}
