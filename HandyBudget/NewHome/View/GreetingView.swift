//
//  GreetingView.swift
//  HandyBudget
//
//  Created by Jadson on 26/08/2025.
//

import UIKit

class GreetingView: UIView {
    
    private lazy var profileImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(systemName: "person.circle")
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 30
        view.tintColor = CustomColors.backGroundColor
        view.clipsToBounds = true
        return view
    }()

    private lazy var greetingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello, User!"
        label.textColor = CustomColors.backGroundColor
        label.font = UIFont(name: "Avenir Heavy", size: 20)
        return label
    }()
    
    private lazy var hideButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        let image = UIImage(systemName: "eye", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = CustomColors.backGroundColor
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension GreetingView: ViewCode {
    func addSubViews() {
        addSubview(profileImageView)
        addSubview(greetingLabel)
        addSubview(hideButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            profileImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            greetingLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 25),
            greetingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            greetingLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            hideButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            hideButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            hideButton.widthAnchor.constraint(equalToConstant: 50),
            hideButton.heightAnchor.constraint(equalToConstant: 50),

        ])
    }
    
    func setupStyle() {
        backgroundColor = CustomColors.greenColor

    }
}
