//
//  CustomButton.swift
//  Handy Budget - Expense Tracker
//
//  Created by Jadson on 12/02/23.
//

import UIKit

class CustomButton: UIButton {
    
    override func awakeFromNib() {
        //MARK: Corner radius
        self.layer.cornerRadius = self.frame.height / 5
        
        //MARK: Shadow
        self.layer.shadowRadius = 10
        self.layer.shadowOpacity = 0.3
        self.layer.shadowColor = UIColor.gray.cgColor
        
        //MARK: - Borders
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.systemGray.cgColor
        
        self.clipsToBounds = true
    }
}

