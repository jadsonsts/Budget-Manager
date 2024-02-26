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
        categoryName.text = category.categoryName
        categoryImage.image = UIImage(systemName: category.iconName)?.imageWithInsets(insets: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
        categoryImage.contentMode = .scaleAspectFit
        categoryImage.layer.cornerRadius = categoryImage.bounds.width / 2
        categoryImage.layer.borderWidth = 0
        categoryImage.backgroundColor = UIColor(hexaRGB: category.color, alpha: 0.2)
        categoryImage.setImageColor(color: UIColor(hexaRGB: category.color, alpha: 1.0) ?? .black)
        categoryImage.clipsToBounds = true
    }
    
}
//MARK: - adding padding to the systemImage
extension UIImage {
    func imageWithInsets(insets: UIEdgeInsets) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width + insets.left + insets.right,
                   height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let _ = UIGraphicsGetCurrentContext()
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets
    }
}

//MARK: - adding foreground color to the systemImage
extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

//MARK: - using hexColor for each category
extension UIColor {
    convenience init?(hexaRGB: String, alpha: CGFloat = 1) {
        var chars = Array(hexaRGB.hasPrefix("#") ? hexaRGB.dropFirst() : hexaRGB[...])
        switch chars.count {
            case 3: chars = chars.flatMap { [$0, $0] }
            case 6: break
            default: return nil
        }
        self.init(red: .init(strtoul(String(chars[0...1]), nil, 16)) / 255,
                  green: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                  blue: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                  alpha: alpha)
    }
    
    convenience init?(hexaRGBA: String) {
        var chars = Array(hexaRGBA.hasPrefix("#") ? hexaRGBA.dropFirst() : hexaRGBA[...])
        switch chars.count {
            case 3: chars = chars.flatMap { [$0, $0] }; fallthrough
            case 6: chars.append(contentsOf: ["F","F"])
            case 8: break
            default: return nil
        }
        self.init(red: .init(strtoul(String(chars[0...1]), nil, 16)) / 255,
                  green: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                  blue: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                  alpha: .init(strtoul(String(chars[6...7]), nil, 16)) / 255)
    }
    
    convenience init?(hexaARGB: String) {
        var chars = Array(hexaARGB.hasPrefix("#") ? hexaARGB.dropFirst() : hexaARGB[...])
        switch chars.count {
            case 3: chars = chars.flatMap { [$0, $0] }; fallthrough
            case 6: chars.append(contentsOf: ["F","F"])
            case 8: break
            default: return nil
        }
        self.init(red: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                  green: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                  blue: .init(strtoul(String(chars[6...7]), nil, 16)) / 255,
                  alpha: .init(strtoul(String(chars[0...1]), nil, 16)) / 255)
    }
}
