//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Dmitrii Seitsman on 07.01.2025.
//
import Foundation
import UIKit

class AlertPresenter {
    
    var alert: UIAlertController?
    
    func presentAlert(model: AlertModel) {
        alert = UIAlertController(title: model.alertTitle, message: model.alertMessage, preferredStyle: .alert)
        guard let alert = self.alert else { return }
        alert.addAction(UIAlertAction(title: model.buttonText, style: .default) {_ in model.completion()})
    }
}


