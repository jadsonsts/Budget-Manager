//
//  CategoriesCollectionViewController.swift
//  BudgetManager
//
//  Created by Jadson on 12/02/23.
//

import UIKit
import ProgressHUD

protocol SelectCategoryDelegate1 {
    func didSelect(category: CategoryElement)
}

class CategoriesCollectionViewController: UICollectionViewController {
    
    var category = [CategoryElement]()
    var selectedCategory: CategoryElement?
    var delegate: SelectCategoryDelegate1?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCategories()
    }
    
    func fetchCategories() {
        DataController.shared.fetchCategories { category in
            self.category = category
            self.collectionView.reloadData()
            ProgressHUD.dismiss()
        } onError: { errorMessage in
            ProgressHUD.showError(errorMessage)
        }
    }
    
    func configureSelectedCell(_ cell: CategoryCollectionViewCell) {
        cell.layer.cornerRadius = cell.bounds.height / 3
        cell.layer.borderWidth = 1
        cell.layer.borderColor = CustomColors.greenColor.cgColor
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return category.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let itemCategory = category[indexPath.row]
        selectedCategory = itemCategory
        collectionView.reloadData()
        delegate?.didSelect(category: selectedCategory!)
        dismiss(animated: true)
    }
}

extension CategoriesCollectionViewController: SelectCategoryDelegate {
    func didSelect(category: CategoryElement) {
    }
}
