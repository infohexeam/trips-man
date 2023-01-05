//
//  LocationSearchViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 17/10/22.
//

import UIKit
import MapKit

class LocationSearchViewController: UIViewController {
    
    @IBOutlet weak var searchField: CustomTextField!
    
    var matchingItems: [MKMapItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        searchField.delegate = self
        
        searchField.addTarget(self, action: #selector(textFieldDidChangedEditing(_:)), for: .editingChanged)
    }
}

extension LocationSearchViewController {
    
    @objc func textFieldDidChangedEditing(_ textField: UITextField) {
        
        if textField.text!.count > 3 {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = textField.text!
            
            request.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 11.266911876256259, longitude: 75.78538542668764), span: MKCoordinateSpan())
            let search = MKLocalSearch(request: request)
            search.start { response, _ in
                guard let response = response else {
                    return
                }
                self.matchingItems = response.mapItems
                print(self.matchingItems)
            }
        }
    }
}
