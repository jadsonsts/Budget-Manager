//
//  CustomColors.swift
//  BudgetManager
//
//  Created by Jadson on 13/02/23.
//

import UIKit

struct CustomColors {
    
    static let backGroundColor = UIColor(named: "backgroundColor")!
    static let expenseLabelColor = UIColor(named: "expenseLabelColor")!
    static let labelColor = UIColor(named: "generalLabelColor")!
    static let greenColor = UIColor(named: "tabBarColor")!
    static let fbColor = UIColor(red: 0.26, green: 0.40, blue: 0.70, alpha: 1.00)
    
//static let borderColor = CGColor(red: 0.00, green: 0.72, blue: 0.67, alpha: 1.0) // Green
//static let errorBorderColor = CGColor(red: 1.00, green: 0.31, blue: 0.31, alpha: 1.00) // LightRed
//static let backgroundColorDark = UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 1.00) // kinda gray
//static let backgroundColorLight = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00) //white
}
//
//extension UIColor {
//    static var myControlBackground: UIColor {
//        if #available(iOS 15.0, *) {
//            return UIColor { (traits) -> UIColor in
//                // Return one of two colors depending on light or dark mode
//                return traits.userInterfaceStyle == .dark ? CustomColors.backgroundColorDark :  CustomColors.backgroundColorLight
//            }
//        } else {
//            // Same old color used for iOS 14 and earlier
//            return UIColor(red: 0.3, green: 0.4, blue: 0.5, alpha: 1)
//        }
//    }
//}
//
//extension UIColor {
//    static var labelColor: UIColor {
//        if #available(iOS 15.0, *) {
//            return UIColor { (traits) -> UIColor in
//                // Return one of two colors depending on light or dark mode
//                return traits.userInterfaceStyle == .light ? CustomColors.backgroundColorDark :  CustomColors.backgroundColorLight
//            }
//        } else {
//            // Same old color used for iOS 14 and earlier
//            return UIColor(red: 0.3, green: 0.4, blue: 0.5, alpha: 1)
//        }
//    }
//}

