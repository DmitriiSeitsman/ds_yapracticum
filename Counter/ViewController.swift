//
//  ViewController.swift
//  Counter
//
//  Created by Dmitrii Seitsman on 01.12.2024.
//

import UIKit
import Foundation

final class ViewController: UIViewController {
    private var counterValue: Int = 0
    private var changeHistory: [String] = []
    private var lastChange: String = "0"
    @IBOutlet private var counter: UILabel!
    @IBOutlet private var plusButton: UIButton!
    @IBOutlet private var minusButton: UIButton!
    @IBOutlet private var textField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    getKeys()
       counter.text = "\(counterValue)"
       textField.text = "\(String(changeHistory.last ?? "история отсутствует"))"
    }
    
    private func getKeys() {
        // Получаем словарь всех значений
        if UserDefaults.standard.dictionaryRepresentation().count != 0 {
            let allValues = UserDefaults.standard.dictionaryRepresentation()
            changeHistory.append(allValues["lastChange"] as? String ?? "история отсутствует")
            counterValue = allValues["counterValue"] as? Int ?? 0
        } else {
            changeHistory.append("0")
            counterValue = 0
        }
        }
    
    //функция обновления истории изменений счетчика
    private func changesHistory() {
        changeHistory.append("[\(Date().formatted(.dateTime))]: значение изменено на \(lastChange)")
        textField.text = changeHistory.joined(separator: "\n")
        let element = changeHistory.last
        UserDefaults.standard.set(element, forKey: "lastChange")
    }
    //Нажатие кнопки плюс
    @IBAction private func counterPush(_ sender: Any) {
        lastChange = "+1"
        counterValue += 1
        counter.text = "\(counterValue)"
        UserDefaults.standard.set(counterValue, forKey: "counterValue")
        changesHistory()
    }
    //Нажатие кнопки минус
    @IBAction private func minusPress(_ sender: Any) {
        lastChange = "-1"
        if counterValue == 0 {
            changeHistory.append("[\(Date().formatted(.dateTime))]: попытка уменьшить значение счетчика ниже 0")
            textField.text = changeHistory.joined(separator: "\n")
            let alert = UIAlertController(title: "Ошибка", message: "0 - минимальное значение счетчика", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            counterValue -= 1
            counter.text = "\(counterValue)"
            UserDefaults.standard.set(counterValue, forKey: "counterValue")
            changesHistory()
        }
    }
//Нажатие кнопки сброс
    @IBAction private func resetPress(_ sender: Any) {
        changeHistory.append("[\(Date().formatted(.dateTime))]: значение сброшено на 0")
        textField.text = changeHistory.joined(separator: "\n")
        counterValue = 0
        counter.text = "\(counterValue)"
        UserDefaults.standard.set(counterValue, forKey: "counterValue")
    }
}

