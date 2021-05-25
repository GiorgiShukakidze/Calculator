//
//  Calculator.swift
//  Calculator
//
//  Created by Giorgi Shukakidze on 7/23/20.
//  Copyright © 2020 Giorgi Shukakidze. All rights reserved.
//

import Foundation

class Calculator {
    private var tokenList = [Token]()
    private var memoryToken = Token(typeValue: .Number)
    private var parenthesesBalance = 0
    
    init() {
        reset()
    }
    
    private func reset() {
        tokenList.removeAll()
        parenthesesBalance = 0
        addNumberToken(0)
    }
    
    private func addNumberToken(_ number: Decimal) {
        let tok = Token(typeValue: .Number)
        tok.numValue = number
        tokenList.append(tok)
    }
    
    private func addOperationToken(_ type: Token.TokenType) {
        let tok = Token(typeValue: type)
        tokenList.append(tok)
    }
    
    private func addOpenParentheses() {
        let tok = Token(typeValue: .OpenParentheses)
        parenthesesBalance += 1
        tokenList.append(tok)
    }
    
    private func addCloseParentheses() {
        guard parenthesesBalance > 0 else { return }

        let tok = Token(typeValue: .CloseParentheses)
        parenthesesBalance -= 1
        tokenList.append(tok)
    }
    
    private func removeCurrentToken() {
        if tokenList.count > 0 {
            tokenList.removeLast()
        }
    }
    
    private func fetchToken() -> Token? {
        if tokenList.count > 0 {
            return tokenList.removeFirst()
        } else {
            return nil
        }
    }
    
    private func currentToken() -> Token? {
        if tokenList.count > 0 {
            return tokenList.last
        } else {
            return nil
        }
    }
    
    private func isParenthesesBalanced() -> Bool {
        return parenthesesBalance == 0
    }
    
    func doMemorySet() {
        if let currentTok = currentToken(), currentTok.isNumber {
            memoryToken.numValue = currentTok.numValue
        }
    }
    
    func doMemoryClear() {
        memoryToken.numValue = 0
    }
    
    func doMemoryRecall() {
        if memoryToken.numValue > 0 {
            if let currentTok = currentToken(), currentTok.isNumber {
                removeCurrentToken()
            }
            
            addNumberToken(memoryToken.numValue)
            currentToken()?.isSealed = true
        }
    }
    
    func doDecimal() {
        if let currentTok = currentToken(), !currentTok.isNumber {
            addNumberToken(0)
        }
        
        if let currentTok = currentToken(), currentTok.decimalFactorValue == 0 {
            currentToken()?.decimalFactorValue = 10
        }
    }
    
    func doDigit(n: Int) {
        
        if let currentTok = currentToken(), currentTok.typeValue == .Number && currentTok.isSealed {
            removeCurrentToken()
            addNumberToken(0)
        }
        
        if let currentTok = currentToken(), currentTok.typeValue == .Number {
            
            if currentTok.decimalFactorValue == 0 {
                currentTok.numValue = (currentTok.numValue * 10) + Decimal(n)
            } else {
                currentTok.numValue += (Decimal(n) / currentTok.decimalFactorValue)
                currentTok.decimalFactorValue *= 10
            }
        } else {
            addNumberToken(Decimal(n))
        }
    }
    
    func doOperator(type: Token.TokenType) {
        
        if let currentTok = currentToken() {
            
            if currentTok.isOperator {
                removeCurrentToken()
            } else if currentTok.isNumber {
                currentTok.isSealed = true
            } else if currentTok.typeValue == .OpenParentheses {
                return
            }
        }
        
        if let currentTok = currentToken(), currentTok.isNumber {
        }
        
        addOperationToken(type)
    }
    
    func doNegative() {
        
        if let currentTok = currentToken(), currentTok.isNumber {
            currentTok.numValue *= -1
        }
    }
    
    func doOneOver() {
        if let currentTok = currentToken(), currentTok.isNumber {
            if currentTok.numValue == 0 {
                currentTok.numValue = 0
            } else {
                currentTok.numValue = 1 / currentTok.numValue
            }
        }
    }
    
    func doClearAll() {
        reset()
    }
    
    func doClearCurrentToken() {
        
        if let currentTok = currentToken() {
            
            if currentTok.isOperator {
                removeCurrentToken()
            } else {
                switch currentTok.typeValue {
                case .Number:
                    if currentTok.numValue == 0 && tokenList.count > 1 {
                        removeCurrentToken()
                    } else {
                        removeCurrentToken()
                        addNumberToken(0)
                    }
                case .OpenParentheses:
                    parenthesesBalance -= 1
                    removeCurrentToken()
                case .CloseParentheses:
                    parenthesesBalance += 1
                    removeCurrentToken()
                default:
                    break
                }
            }
        }
    }
    
    func doPercent() {
        if let currentTok = currentToken(), currentTok.isNumber {
            currentToken()?.numValue /= 100
        }
    }
    
    func doParentheses(type: Token.TokenType) {
        if let currentTok = currentToken() {
            switch type {
            case .OpenParentheses:
                
                if currentTok.isNumber && !currentTok.isSealed {
                    removeCurrentToken()
                    addOpenParentheses()
                } else if currentTok.isOperator || currentTok.typeValue == .OpenParentheses {
                    addOpenParentheses()
                }
            case .CloseParentheses:
                
                if currentTok.isOperator && parenthesesBalance > 0 {
                    removeCurrentToken()
                } else if tokenList.count <= 1 || currentTok.typeValue == .OpenParentheses {
                    break
                }
                
                currentTok.isSealed = currentTok.isNumber
                addCloseParentheses()
            default:
                break
            }
        }
    }
    
    private func tokenEvalBinOp(tokOp: Token, aTok: Token, bTok: Token) -> Token {
        
        let result = Token(typeValue: .Number)
        
        switch tokOp.typeValue {
        case .Add:
            result.numValue = aTok.numValue + bTok.numValue
        case .Subtract:
            result.numValue = aTok.numValue - bTok.numValue
        case .Multiply:
            result.numValue = aTok.numValue * bTok.numValue
        case .Divide:
            result.numValue = aTok.numValue / bTok.numValue
        default:
            break
        }
        
        return result
    }
    
    private func doBinaryEval(operators: inout [Token], numbers: inout [Token]) {
        
        let topOperationToken = operators.removeLast()
        let bToken = numbers.removeLast()
        let aToken = numbers.removeLast()
        
        numbers.append(tokenEvalBinOp(tokOp: topOperationToken, aTok: aToken, bTok: bToken))
    }
    
    private func doBinaryEval2(operators: inout [Token], numbers: inout [Token]) {
        
        let topOperationToken = operators.removeLast()
        let aToken = numbers.removeLast()
        let bToken = numbers.removeLast()
        
        numbers.append(tokenEvalBinOp(tokOp: topOperationToken, aTok: aToken, bTok: bToken))
    }
    
    func calculate(completed: (Result<Decimal, CalcErrors>) -> Void) {
        
        guard isParenthesesBalanced() else {
            completed(.failure(.NotBalanced))
            return
        }
        
        if let currentTok = currentToken(), currentTok.isOperator {
            removeCurrentToken()
        }

        // Make calculations in parentheses
        
        var finalTokenList = [Token]()
        var tokensWithParentheses = [Token]()
        var openParenthesesIndices = [Int]()

        for n in 0..<tokenList.count {
            let token = tokenList[n]
            
            if token.typeValue == .OpenParentheses {
                
                openParenthesesIndices.append(tokensWithParentheses.count)
                tokensWithParentheses.append(token)
            } else if token.typeValue == .CloseParentheses {
                
                let lastOpenIndex = openParenthesesIndices.last!
                let finalIndex = tokensWithParentheses.count - 1
                let operationInsideParentheses = Array(tokensWithParentheses[lastOpenIndex + 1...finalIndex])
                
                if let result = evaluate(tokenArray: operationInsideParentheses) {
                    tokensWithParentheses.removeSubrange(lastOpenIndex...finalIndex)
                    
                    if tokensWithParentheses.count > 0 {
                        tokensWithParentheses.append(result)
                    } else {
                        finalTokenList.append(result)
                    }
                    openParenthesesIndices.removeLast()
                }
            } else if openParenthesesIndices.count > 0 {
                tokensWithParentheses.append(token)
            } else {
                finalTokenList.append(token)
            }
        }
        
        if let finalToken = evaluate(tokenArray: finalTokenList) {
            reset()
            removeCurrentToken()
            addNumberToken(finalToken.numValue)
            currentToken()?.isSealed = true
            completed(.success(finalToken.numValue))
        }
    }
    
    private func evaluate(tokenArray: [Token]) -> Token? {
        guard tokenArray.count > 0 else { return nil }

        var operatorsList = [Token]()
        var numbersList = [Token]()
        var operatorsList2 = [Token]()
        var numbersList2 = [Token]()
                
        tokenArray.forEach { (token) in
            if token.isNumber {
                numbersList.append(token)
            } else if token.isOperator {
                
                if operatorsList.count > 0 {
                    
                    if let lastOperator = operatorsList.last,
                        token.isLessThanOrEqualTo(tokenCompare: lastOperator) {
                        
                        doBinaryEval(operators: &operatorsList, numbers: &numbersList)
                    }
                }
                
                operatorsList.append(token)
            }
        }
        
        if operatorsList.last?.typeValue == Token.TokenType.Divide ||
            operatorsList.last?.typeValue == Token.TokenType.Multiply {
            
            doBinaryEval(operators: &operatorsList, numbers: &numbersList)
        }
        
        while numbersList.count > 0 {
            numbersList2.append(numbersList.removeLast())
        }
        
        while operatorsList.count > 0 {
            operatorsList2.append(operatorsList.removeLast())
        }
        
        while operatorsList2.count > 0 {
            doBinaryEval2(operators: &operatorsList2, numbers: &numbersList2)
        }
        
        if let finalToken = numbersList2.last {
            finalToken.isSealed = true
            return finalToken
        } else {
            return nil
        }
    }
    
    func getTokensStrings() -> String {
        var resultString = ""
        
        tokenList.forEach { (token) in
            resultString += token.stringValue
        }
        
        return resultString
    }
}

enum CalcErrors: Error {
    case NotBalanced
}
