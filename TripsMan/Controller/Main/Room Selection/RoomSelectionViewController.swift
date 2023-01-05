//
//  RoomSelectionViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 27/09/22.
//

import UIKit

class RoomSelectionViewController: UIViewController {
        
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.collectionViewLayout = createLayout()
            collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            collectionView.dataSource = self
            //                collectionView.delegate = self
        }
    }
    
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var pickerContainer: UIView!
    
    enum SectionTypes {
        case summary
        case primaryFields
        case guestFields
        case actions
    }
    
    struct RoomSelectionSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [RoomSelectionSection]? = nil
    
    var fontSize: CGFloat? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addBackButton(with: "Room Selection")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerContainer.isHidden = true
        sections = [RoomSelectionSection(type: .summary, count: 1),
                    RoomSelectionSection(type: .primaryFields, count: 1),
                    RoomSelectionSection(type: .guestFields, count: 1),
                    RoomSelectionSection(type: .actions, count: 1)]
        
        collectionView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
    }
    
}

extension RoomSelectionViewController {
    
    @IBAction func addGuestTapped(_ sender: UIButton) {
        sections?.removeLast()
        sections?.append(RoomSelectionSection(type: .guestFields, count: 1))
        sections?.append(RoomSelectionSection(type: .actions, count: 1))
        collectionView.reloadData()
    }
    
    @IBAction func continueTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toRoomSelectionSummary", sender: nil)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pickerSelectTapped(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func outsiderPickerTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func genderButtonTapped(_ sender: UIButton) {
        print("tapped")
        pickerContainer.isHidden = false
        print(sender.tag)
    }
    
}


extension RoomSelectionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = sections?[section] else { return 0 }
        
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let thisSection = sections?[indexPath.section] else { return UICollectionViewCell() }
        
        if thisSection.type == .summary {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "roomSummaryCell", for: indexPath) as! RoomSummaryCollectionViewCell
            
            if fontSize == nil {
                fontSize = cell.priceLabel.font.pointSize
            }
            cell.priceLabel.addPriceString("3999", "2999", fontSize: fontSize!)
            
            return cell
            
        } else if thisSection.type == .primaryFields {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "primaryFieldCell", for: indexPath) as! PrimaryFieldCollectionViewCell
            cell.delegate = self
            cell.setupView()
            cell.genderButton.tag = indexPath.section

            
            return cell
        } else if thisSection.type == .guestFields {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "guestFieldCell", for: indexPath) as! GuestFieldCollectionViewCell
            
            cell.delegate = self
            cell.setupView()
            cell.genderButton.tag = indexPath.section

            
            return cell
        } else if thisSection.type == .actions {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "actionsCell", for: indexPath) as! RoomSelectionActionsCollectionViewCell
            
            return cell
        } else {
            fatalError("Unknown section!")
        }
        
    }
    
    
}

extension RoomSelectionViewController: DynamicCellHeightDelegate {
    func updateHeight() {
        collectionView.collectionViewLayout.invalidateLayout()
        print("----*****")
    }
    
    
}


//MARK: - PickerView
extension RoomSelectionViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Male"
        } else {
            return "Female"
        }
    }
    
}

//MARK: - Layout
extension RoomSelectionViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
//            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            
            guard let thisSection = self.sections?[sectionIndex] else { return nil }
            
            let section: NSCollectionLayoutSection
            
            
            if thisSection.type == .summary {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(200))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
                
            } else if thisSection.type == .primaryFields {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(44))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(44))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
            } else if thisSection.type == .guestFields {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(44))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(44))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
            } else if thisSection.type == .actions {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(44))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(44))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
            } else {
                fatalError("Unknown section!")
            }
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    func updateLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
//            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            
            guard let thisSection = self.sections?[sectionIndex] else { return nil }
            
            let section: NSCollectionLayoutSection
            
            
            if thisSection.type == .primaryFields {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(44))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(44))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
            }  else {
                fatalError("Unknown section!")
            }
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}


protocol DynamicCellHeightDelegate {
    func updateHeight()
}
