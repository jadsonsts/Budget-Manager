//
//  CategoriesCollectionViewController.swift
//  BudgetManager
//
//  Created by Jadson on 12/02/23.
//

import UIKit

protocol SelectCategoryDelegate {
    func didSelect(category: CategoryElement)
}

class CategoriesCollectionViewController: UICollectionViewController {
    
    var category = [CategoryElement]()
    var selectedCategory: CategoryElement?
    var delegate: SelectCategoryDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAllCategories()
        
    }
    
    func fetchAllCategories() {
        if let path = Bundle.main.path(forResource: "Categories", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let newResponse = try JSONDecoder().decode(Category.self, from: data)
                
                DispatchQueue.main.async { [self] in
                    category = newResponse
                    collectionView.reloadData()
                }
                
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
        }
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return category.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.categoryCell, for: indexPath) as? CategoryCollectionViewCell {
            let category = category[indexPath.row]
            cell.updateViews(category: category)
            
            if category == self.selectedCategory {
                cell.layer.cornerRadius = 2
            }
            
            return cell
        } else {
            return CategoryCollectionViewCell()
        }
    }

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
//        if let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell {
//            cell.layer.cornerRadius = 1
//            cell.layer.borderWidth = 1
//            cell.layer.borderColor = CustomColors.greenColor.cgColor
//        }
        
    }



}
