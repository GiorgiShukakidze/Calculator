//
//  Number.swift
//  Calculator
//
//  Created by Giorgi Shukakidze on 7/24/20.
//  Copyright © 2020 Giorgi Shukakidze. All rights reserved.
//

import Foundation

class Token {
    
    private let symbols = ["+", "-", "x", "/", "(", ")"]
    let typeValue: TokenType
    var numValue: Decimal = 0
    var decimalFactorValue:Decimal = 0
    var isSealed: Bool = false
    var isOperator: Bool {
        return (typeValue.rawValue >= TokenType.Add.rawValue && typeValue.rawValue <= TokenType.Divide.rawValue)
    }
    var isNumber: Bool {
        return typeValue == TokenType.Number
    }
    var stringValue: String {
        if !isNumber {
            return symbols[typeValue.rawValue]
        } else {
                return "\(numValue)"
        }
    }
    
    func isLessThanOrEqualTo(tokenCompare: Token) -> Bool {
        return self.typeValue.rawValue <= tokenCompare.typeValue.rawValue
    }
    
    init(typeValue: TokenType) {
        self.typeValue = typeValue
    }
    
    enum TokenType: Int {
        case Add = 0
        case Subtract
        case Multiply
        case Divide
        case OpenParentheses
        case CloseParentheses
        case Number
    }
}
