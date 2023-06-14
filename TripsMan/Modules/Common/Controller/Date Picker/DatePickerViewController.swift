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

    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.tag = pickerTag
        datePicker.minimumDate = minDate

    }
    
    
    @IBAction func datePickerDoneTapped(_ sender: UIBarButtonItem) {
        delegate?.datePickerDoneTapped(date: datePicker.date, tag: pickerTag)
        self.dismiss(animated: true)
    }
}


protocol DatePickerDelegate {
    func datePickerDoneTapped(date: Date, tag: Int)
}
