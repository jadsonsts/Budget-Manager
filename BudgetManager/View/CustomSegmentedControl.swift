//
//  CustomSegmentedControl.swift
//  BudgetManager
//
//  Created by Jadson on 13/02/23.
//

import UIKit

class CustomSegmentedControl: UISegmentedControl {
    
}

extension UIImage {
    class func getSegRect(color: CGColor, andSize size: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color)
        let rectangle = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        context?.fill(rectangle)
        
        let rectangleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return rectangleImage!
    }
}

//MARK: - Extension for UISegmented Control

extension UISegmentedControl {
        
    func removeBorder() {
        
        self.backgroundColor = .clear
        let segmentWidth = self.bounds.width / CGFloat(self.numberOfSegments)
        let segmentHeight: CGFloat = 2
        self.bounds.size = CGSize(width: segmentWidth, height: segmentHeight)
        self.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        self.setBackgroundImage(UIImage(), for: .selected, barMetrics: .default)
        self.setBackgroundImage(UIImage(), for: .highlighted, barMetrics: .default)
        
        let deviderLine = UIImage.getSegRect(color: CustomColors.greenColor.cgColor, andSize: CGSize(width: 0.3, height: 5))
        self.setDividerImage(deviderLine, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        self.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
        self.setTitleTextAttributes([.foregroundColor: UIColor(cgColor: CustomColors.greenColor.cgColor)], for: .selected)
    }
    
    //MARK: - Tab Highlight when selected
    
    func hightlightSelectedSegment() {
        removeBorder()
        let lineWidth: CGFloat = self.bounds.size.width / CGFloat(self.numberOfSegments)
        let lineHeight: CGFloat = 3.0 //set height underline height
        let lineXPosition = CGFloat(selectedSegmentIndex * Int(lineWidth))
        let lineYPosition = self.bounds.size.height - 4.0
        let underLineFrame = CGRect(x: lineXPosition, y: lineYPosition, width: lineWidth, height: lineHeight)
        let underLine = UIView(frame: underLineFrame)
        underLine.backgroundColor = UIColor(cgColor: CustomColors.greenColor.cgColor)
        underLine.tag = 1
        self.addSubview(underLine)
        
    }
    
    //MARK: - Set the position of bottom line
    
    func underlinePosition() {
        guard let underline = self.viewWithTag(1) else { return }
        let xPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(selectedSegmentIndex)
        
        // Animation when change tab
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseInOut) {
            underline.frame.origin.x = xPosition
        }
    }
}
