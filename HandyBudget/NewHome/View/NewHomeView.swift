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

    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            greetingView.topAnchor.constraint(equalTo: topAnchor),
            greetingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            greetingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            greetingView.heightAnchor.constraint(equalToConstant: 200)

        ])
    }
    
    func setupStyle() {
        backgroundColor = CustomColors.backGroundColor
        greetingView.backgroundColor = CustomColors.greenColor
        
    }
}
