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
        return view
    }()

    private lazy var greetingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello, World!"
        return label
    }()
    
    private lazy var hideButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "eye"), for: .normal)
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
            
            profileImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            hideButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            hideButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            greetingLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 40),
            greetingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
        ])
    }
    
    func setupStyle() {
        backgroundColor = CustomColors.backGroundColor
        profileImageView.layer.cornerRadius = 40
        
    }
    
    
}
