//
//  ViewController.swift
//  Counter
//
//  Created by Dmitrii Seitsman on 01.12.2024.
//

import UIKit
class ViewController: UIViewController {
var counterDigit: Int = 0
    @IBOutlet var Button: UIButton!
    @IBAction func counterPush(_ sender: Any) {
        counterDigit += 1
        counter.text = "\(counterDigit)"
    }
    @IBOutlet var counter: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        counter.text = "\(counterDigit)"
        // Do any additional setup after loading the view.
    }


}

