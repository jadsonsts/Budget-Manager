//
//  CategoryCollectionViewCell.swift
//  BudgetManager
//
//  Created by Jadson on 6/03/23.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    
    
    func updateViews(category: CategoryElement) {
        categoryName.text = category.name
        categoryImage.image = UIImage(systemName: category.iconName)
        
//        categoryImage.layer.borderWidth = 1
        categoryImage.layer.masksToBounds = false
//        categoryImage.layer.borderColor = CustomColors.labelColor.cgColor
//        categoryImage.layer.cornerRadius = categoryImage.frame.size.height / 2
        
        categoryImage.clipsToBounds = false
        
        
        
    }
    
}
