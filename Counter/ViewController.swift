//
//  ViewController.swift
//  Counter
//
//  Created by Dmitrii Seitsman on 01.12.2024.
//

import UIKit
import Foundation
//var dateAndTime = Date().formatted(.dateTime)
var counterDigit: Int = 0
var arrayOfchanges: [String] = []
var digit: String = "0"
class ViewController: UIViewController {
    @IBOutlet var counter: UILabel!
    @IBOutlet var plusButton: UIButton!
    @IBOutlet var minusButton: UIButton!
    @IBOutlet var textField: UITextView!
    //функция обновления текстового поля
    func changesHistory() {
        arrayOfchanges.append("[\(Date().formatted(.dateTime))]: значение изменено на \(digit)")
        textField.text = arrayOfchanges.joined(separator: "\n")
    }
    //Нажатие кнопки плюс
    @IBAction func counterPush(_ sender: Any) {
        digit = "+1"
        counterDigit += 1
        counter.text = "\(counterDigit)"
        changesHistory()
    }
    //Нажатие кнопки минус
    @IBAction func minusPress(_ sender: Any) {
        digit = "-1"
        if counter.text == "0" {
            arrayOfchanges.append("[\(Date().formatted(.dateTime))]: попытка уменьшить значение счетчика ниже 0")
            textField.text = arrayOfchanges.joined(separator: "\n")
            let alert = UIAlertController(title: "Ошибка", message: "0 - минимальное значение счетчика", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            counterDigit -= 1
            counter.text = "\(counterDigit)"
            changesHistory()
        }
    }
//Нажатие кнопки сброс
    @IBAction func resetPress(_ sender: Any) {
        arrayOfchanges.append("[\(Date().formatted(.dateTime))]: значение сброшено на 0")
        textField.text = arrayOfchanges.joined(separator: "\n")
        counterDigit = 0
        counter.text = "\(counterDigit)"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        counter.text = "\(counterDigit)"
        textField.text = "История изменений:"
    }
}

