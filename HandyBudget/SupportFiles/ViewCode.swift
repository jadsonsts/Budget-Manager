//
//  ViewCode.swift
//  HandyBudget
//
//  Created by Jadson on 28/08/2025.
//

protocol ViewCode {
    func addSubViews()
    func setupConstraints()
    func setupStyle()
    
}

extension ViewCode {
    func setup() {
        addSubViews()
        setupConstraints()
        setupStyle()
    }
}
