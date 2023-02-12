//
//  CustomTxtField.swift
//  BudgetManager
//
//  Created by Jadson on 12/02/23.
//

import UIKit

class CustomTxtField: UITextField {
    
    let borderColor = CGColor(red: 0.00, green: 0.72, blue: 0.67, alpha: 1.0)
    let errorBorderColor = CGColor(red: 1.00, green: 0.31, blue: 0.31, alpha: 1.00)

    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.height / 4
        self.layer.borderColor = borderColor
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
        layer.borderColor = UIColor.red.cgColor
    }
    
    func hideError() {
        layer.borderWidth = 0
        layer.borderColor = nil
    }
}

//extension UIColor {
//    func borderColor() -> UIColor {
//        return UIColor(cgColor: CGColor(red: 0.00, green: 0.72, blue: 0.67, alpha: 1.0))
//    }
//}
