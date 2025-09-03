//
//  NewHome.swift
//  HandyBudget
//
//  Created by Jadson on 26/08/2025.
//

import UIKit

class NewHomeView: UIView {

    lazy var greetingView:  GreetingView = {
        let view = GreetingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var balanceView:  BalanceView = {
        let view = BalanceView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension NewHomeView: ViewCode {
    func addSubViews() {
        addSubview(greetingView)
        addSubview(balanceView)

    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            greetingView.topAnchor.constraint(equalTo: topAnchor),
            greetingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            greetingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            greetingView.heightAnchor.constraint(equalToConstant: 200),
            
            balanceView.topAnchor.constraint(equalTo: greetingView.bottomAnchor, constant: 0),
            balanceView.leadingAnchor.constraint(equalTo: leadingAnchor),
            balanceView.trailingAnchor.constraint(equalTo: trailingAnchor),
            balanceView.heightAnchor.constraint(equalToConstant: 150),

        ])
    }
    
    func setupStyle() {
        backgroundColor = CustomColors.backGroundColor
        greetingView.backgroundColor = CustomColors.greenColor
//        balanceView.backgroundColor = .systemCyan
        
    }
}
