//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Dmitrii Seitsman on 07.01.2025.
//
import Foundation

struct AlertModel {
    
    let alertTitle: String
    let alertMessage: String
    let buttonText: String
    let completion: () -> ()
    
    init(alertTitle: String, alertMessage: String, buttonText: String, completion: @escaping () -> Void) {
        self.alertTitle = alertTitle
        self.alertMessage = alertMessage
        self.buttonText = buttonText
        self.completion = completion
    }
}
