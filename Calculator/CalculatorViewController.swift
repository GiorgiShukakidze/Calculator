//
//  ViewController.swift
//  Calculator
//
//  Created by Giorgi Shukakidze on 7/23/20.
//  Copyright © 2020 Giorgi Shukakidze. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    private var calculator = Calculator()
    
    //MARK: -  IB Outlets
    

    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    //MARK: - IB Actions
    
    @IBAction func calcButtonPressed(_ sender: UIButton) {
        
        switch sender.currentTitle {
        case "x":
            calculator.doOperator(type: .Multiply)
        case "/":
            calculator.doOperator(type: .Divide)
        case "-":
            calculator.doOperator(type: .Subtract)
        case "+":
            calculator.doOperator(type: .Add)
        case "CE":
            calculator.doClearCurrentToken()
        case "+/-":
            calculator.doNegative()
        case "%":
            calculator.doPercent()
        case "C":
            calculator.doClearAll()
        case "M+":
            calculator.doMemorySet()
        case "MC":
            calculator.doMemoryClear()
        case "MR":
            calculator.doMemoryRecall()
        case "1/x":
            calculator.doOneOver()
        default:
            break
        }
        
        displayLabel.text = calculator.getTokensStrings()
    }
    
    @IBAction func numButtonPressed(_ sender: UIButton) {
        
        if let title = sender.currentTitle {
            
            if title == "."{
                calculator.doDecimal()
            } else if let numValue = Int(title){
                calculator.doDigit(n: numValue)
            }
        }
                
        displayLabel.text = calculator.getTokensStrings()
    }
    
    @IBAction func equationPressed(_ sender: UIButton) {
        
        calculator.calculate { (result) in
            switch result {
            case .success(let number):
                displayLabel.text = "\(number)"
            case .failure:
                showAlert(title: "Brackets not balanced", message: "Number of parentheses do not match. Please check equation.")
            }
        }
    }
    
    @IBAction func parenthesesPressed(_ sender: UIButton) {
        switch sender.currentTitle {
        case "(":
            calculator.doParentheses(type: .OpenParentheses)
        case ")":
            calculator.doParentheses(type: .CloseParentheses)
        default:
            break
        }
        
        displayLabel.text = calculator.getTokensStrings()
    }
    
    //MARK: - Utilities
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
}

