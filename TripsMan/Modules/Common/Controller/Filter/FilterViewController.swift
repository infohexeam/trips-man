//
//  FilterViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 16/01/23.
//

import UIKit
import RangeSeekSlider

class FilterViewController: UIViewController {
    
    @IBOutlet weak var filterCollectionView: UICollectionView! {
        didSet {
            filterCollectionView.collectionViewLayout = createLayout()
            filterCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            filterCollectionView.dataSource = self
            filterCollectionView.allowsMultipleSelection = true
            filterCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
//            filterCollectionView.delegate = self
        }
    }
    
    @IBOutlet weak var resetButton: UIButton!
    
    enum SectionTypes {
        case list
        case range
    }
    
    struct FilterListSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [FilterListSection]? = nil
    
    var filters = [Filte]()
    
    var sliderLowerValue = K.minimumPrice
    var sliderUpperValue = K.maximumPrice
    
    var delegate: FilterDelegate?
    var selectedIndexes = [IndexPath]()
    var selectedRates: Rate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Filter by"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sections = [FilterListSection(type: .range, count: 1)]
        for filter in filters {
            sections?.append(FilterListSection(type: .list, count: filter.values.count))
        }
        
        filterCollectionView.reloadData()
        for index in selectedIndexes {
            filterCollectionView.selectItem(at: index, animated: true, scrollPosition: .top)
        }
        
        if let selectedRates = selectedRates {
            sliderUpperValue = Double(selectedRates.to)
            sliderLowerValue = Double(selectedRates.from)
        }
    }
    
    
    @IBAction func resetButtonTapped(_ sender: UIBarButtonItem) {
        selectedRates = nil
        selectedIndexes.removeAll()
        filterCollectionView.reloadData()
    }
}

//MARK: - IBActions
extension FilterViewController {
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        
        delegate?.filterSearchTapped(minimumPrice: sliderLowerValue, maximumPrice: sliderUpperValue, filterIndexes: filterCollectionView.indexPathsForSelectedItems)
        dismiss(animated: true)
    }
    
    
    @IBAction func sliderValueChanged(_ sender: RangeSeekSlider) {
        sliderLowerValue = sender.selectedMinValue
        sliderUpperValue = sender.selectedMaxValue
    }
    
}


//MARK: - UICollectionView
extension FilterViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = self.sections?[section] else { return 0 }

        return thisSection.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let thisSection = self.sections?[indexPath.section] else { return UICollectionViewCell()  }

        if thisSection.type == .list {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterListCell", for: indexPath) as! FilterListCollectionViewCell
            
            let data = filters[indexPath.section - 1].values[indexPath.row]
            cell.valueLabel.text = data.name

            return cell
        }
        
        if thisSection.type == .range {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterRangeCell", for: indexPath) as! FilterRangeCollectionViewCell
            
            cell.rangeSlider.maxValue = K.maximumPrice
            cell.rangeSlider.minValue = K.minimumPrice
            if let selectedRates = selectedRates {
                cell.rangeSlider.selectedMaxValue = Double(selectedRates.to)
                cell.rangeSlider.selectedMinValue = Double(selectedRates.from)
            } else {
                cell.rangeSlider.selectedMaxValue = K.maximumPrice
                cell.rangeSlider.selectedMinValue = K.minimumPrice
            }
            cell.rangeSlider.maxValue = K.maximumPrice  //needed for reset to work properly
            cell.rangeSlider.minValue = K.minimumPrice
            
            return cell
        }

        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "filterHeader", for: indexPath) as! FiltersHeaderView
            
            guard let thisSection = sections?[indexPath.section] else { return headerView }
            
            if thisSection.type == .list {
                let data = filters[indexPath.section - 1]
                headerView.titleLabel.text = data.title
            } else if thisSection.type == .range {
                headerView.titleLabel.text = "Price Range"
            }
            
            return headerView
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "filterFooter", for: indexPath) as! FilterFooterView
            
//            guard let thisSection = sections?[indexPath.section] else { return footerView }
            
            
            return footerView
            
        default:
            return UICollectionReusableView()
//            assert(false, "Invalid Element Type")
        }
    }
}

extension FilterViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension FilterViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let containerWidth = layoutEnvironment.container.effectiveContentSize.width

            guard let thisSection = self.sections?[sectionIndex] else { return nil }

            let section: NSCollectionLayoutSection


            if thisSection.type == .list {
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(20),
                                                      heightDimension: .estimated(20))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(20))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(10)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .estimated(25))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                
                let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .estimated(25))
                let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)

                section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
                section.interGroupSpacing = 8
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)

            } else if thisSection.type == .range {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(20))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(20))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(10)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .estimated(25))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                
                let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .estimated(25))
                let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)

                section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
                section.interGroupSpacing = 8
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)

            } else {
                fatalError("Unknown section!")
            }

            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}


protocol FilterDelegate {
    func filterSearchTapped(minimumPrice: Double, maximumPrice: Double, filterIndexes: [IndexPath]?)
}
