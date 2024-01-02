//
//  SelectCategoryViewController.swift
//  BudgetManager
//
//  Created by Jadson on 9/12/23.
//

import UIKit
import ProgressHUD

protocol SelectCategoryDelegate {
    func didSelect(category: CategoryElement)
}

class SelectCategoryViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    var category = [CategoryElement]()
    var selectedCategory: CategoryElement?
    var delegate: SelectCategoryDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        fetchCategories()

    }
    
    func fetchCategories() {
        DataController.shared.fetchCategories { [weak self] category in
            self?.category = category
            self?.categoryCollectionView.reloadData()
            ProgressHUD.dismiss()
            
        } onError: { errorMessage in
            ProgressHUD.showError(errorMessage)
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func configureSelectedCell(_ cell: CategoryCollectionViewCell) {
        cell.layer.cornerRadius = cell.bounds.height / 3
        cell.layer.borderWidth = 1
        cell.layer.borderColor = CustomColors.greenColor.cgColor
    }
    
}

// MARK: UICollectionViewDataSource
extension SelectCategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return category.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.categoryCell, for: indexPath) as? CategoryCollectionViewCell {
            let category = category[indexPath.row]
            cell.updateViews(category: category)
            
            if category == self.selectedCategory {
                configureSelectedCell(cell)
            } else {
                cell.layer.borderWidth = 0
            }
            
            return cell
        } else {
            return CategoryCollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let itemCategory = category[indexPath.row]
        selectedCategory = itemCategory
        collectionView.reloadData()
        delegate?.didSelect(category: selectedCategory!)
        dismiss(animated: true)
    }
    
}
