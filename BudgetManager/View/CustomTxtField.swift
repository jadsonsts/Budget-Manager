//
//  CustomTxtField.swift
//  BudgetManager
//
//  Created by Jadson on 12/02/23.
//

import UIKit

class CustomTxtField: UITextField {

    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.height / 4
        self.layer.borderColor = CustomColors.greenColor.cgColor
        self.layer.borderWidth = 1
    }
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

}

extension UITextField {
    func showError() {
        layer.borderWidth = 1
        layer.borderColor = CustomColors.expenseLabelColor.cgColor
    }
    
    func hideError() {
        layer.borderWidth = 0
        layer.borderColor = nil
    }
}

