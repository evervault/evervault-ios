//
//  File.swift
//  
//
//  Created by Eoin Boylan on 03/05/2024.
//

import Foundation

/// Configuration for validating payment card data fields.
public struct PaymentCardValidationConfig: Equatable {
    var validateCardNumber: Bool = true
    var validateExpiry: Bool = true
    var validateCVC: Bool = true
    
    public init(validateCardNumber: Bool = true, validateExpiry: Bool = true, validateCVC: Bool = true) {
        self.validateCardNumber = validateCardNumber
        self.validateExpiry = validateExpiry
        self.validateCVC = validateCVC
    }
}
