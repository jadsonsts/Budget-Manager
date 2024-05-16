//
//  SelectCategoryViewController.swift
//  BudgetManager
//
//  Created by Jadson on 9/12/23.
//

import UIKit
import ProgressHUD
import FirebaseDatabase
import FirebaseStorage

protocol SelectCategoryDelegate {
    func didSelect(category: CategoryElement)
}

class SelectCategoryViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    var category = Category()
    var selectedCategory: CategoryElement?
    var delegate: SelectCategoryDelegate?
    
    let databaseRef = Database.database().reference()

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
    
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func configureSelectedCell(_ cell: CategoryCollectionViewCell) {
        // Create a container view for the image
        let imageContainerView = UIView(frame: cell.categoryImage.frame)
        imageContainerView.layer.cornerRadius = cell.categoryImage.bounds.width / 2
        imageContainerView.layer.borderWidth = 2
        imageContainerView.layer.borderColor = CustomColors.greenColor.cgColor
        cell.contentView.addSubview(imageContainerView)
        
        // Create a check mark image view
        let checkmarkImageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.tintColor = CustomColors.greenColor
        checkmarkImageView.backgroundColor = CustomColors.backGroundColor
        checkmarkImageView.frame = CGRect(x: imageContainerView.bounds.width - 10, y: 2, width: 25, height: 25)
        checkmarkImageView.layer.cornerRadius = checkmarkImageView.bounds.width / 2
        checkmarkImageView.layer.borderWidth = 3
        checkmarkImageView.layer.borderColor = CustomColors.backGroundColor.cgColor
        cell.contentView.addSubview(checkmarkImageView)
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
    
    func fetchCategories() {
        ProgressHUD.animate("Loading Categories...", .barSweepToggle)
        DataController.shared.fetchCategories { [weak self] categoryDictionary in
            self?.category = categoryDictionary
            self?.categoryCollectionView.reloadData()
            ProgressHUD.dismiss()
        } onError: { errorMessage in
            ProgressHUD.failed("Unable to fetch categories")
        }
    }
}
