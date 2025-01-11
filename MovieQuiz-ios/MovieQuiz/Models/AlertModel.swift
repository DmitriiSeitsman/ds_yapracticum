//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Dmitrii Seitsman on 07.01.2025.
//
import Foundation
import UIKit

struct AlertModel {
    
    var alertTitle: String
    var alertMessage: String
    var buttonText: String
    var completion: () -> ()
    
    init(alertTitle: String, alertMessage: String, buttonText: String, completion: @escaping () -> Void) {
        self.alertTitle = alertTitle
        self.alertMessage = alertMessage
        self.buttonText = buttonText
        self.completion = completion
    }
}
