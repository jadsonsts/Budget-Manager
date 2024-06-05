//
//  PasswordValidatonObj.swift
//  BudgetManager
//
//  Created by Jadson on 29/03/23.
//

import Foundation

class PasswordValidationObj {
    var password = "" {
        didSet {
            validations = validate(password: password)
            isValid = validations.filter { $0.state == .failure }.isEmpty
            onChange?(self)
        }
    }
    var validations: [Validation] = []
    var isValid: Bool = false
    var onChange: ((PasswordValidationObj) -> Void)?
    
    private func validate(password: String) -> [Validation] {
        var validations: [Validation] = []
        validations.append(Validation(string: password,
                                      id: 0,
                                      field: .password,
                                      validationType: .isNotEmpty))
        validations.append(Validation(string: password,
                                      id: 1,
                                      field: .password,
                                      validationType: .minCharacters(min: 8)))
        validations.append(Validation(string: password,
                                      id: 2,
                                      field: .password,
                                      validationType: .hasSymbols))
        validations.append(Validation(string: password,
                                      id: 3,
                                      field: .password,
                                      validationType: .hasUppercasedLetters))
        validations.append(Validation(string: password,
                                      id: 4,
                                      field: .password,
                                      validationType: .hasLowercasedLetters))
        validations.append(Validation(string: password,
                                      id: 5,
                                      field: .password,
                                      validationType: .hasNumbers))
        return validations
    }
}
