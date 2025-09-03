//
//  BalanceView.swift
//  HandyBudget
//
//  Created by Jadson on 01/09/2025.
//

import UIKit

class BalanceView: UIView {
    
    
    private lazy var disclaimerLabel = simpleLabel(text: "Manual Account", font: UIFont(name: "Avenir Heavy", size: 17))
    private lazy var currentBalanceLabel = simpleLabel(text: "Current balance", font: UIFont(name: "Avenir Book", size: 15))
    private lazy var balanceAmountLabel = simpleLabel(text: "$123.45", font: nil)
    


    private lazy var informationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        let image = UIImage(systemName: "info.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = CustomColors.greenColor
        return button
    }()
    
    private lazy var disclaimerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [disclaimerLabel, informationButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var balanceStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currentBalanceLabel, balanceAmountLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = -5
        return stackView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [disclaimerStackView, balanceStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally //review when all views are done
        stackView.spacing = 5
        return stackView
    }()
    
    init() {
        super.init(frame: .zero)
        setup()
        
        let attributedString = NSMutableAttributedString(string: disclaimerLabel.text ?? "")
        
        // Add the underline attribute
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0, length: attributedString.length))
        
        disclaimerLabel.attributedText = attributedString
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension BalanceView: ViewCode {
    func addSubViews() {

        addSubview(stackView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10),
            
        ])
      
    }
    
    func setupStyle() {

    }
    
    
}

final class simpleLabel: UILabel {
    
    init(text: String, font: UIFont?) {
        super.init(frame: .zero)
        self.text = text
        self.textColor = CustomColors.labelColor
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if (font != nil) {
            self.font = font
        } else {
            self.font = UIFont(name: "Avenir Heavy", size: 22)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
