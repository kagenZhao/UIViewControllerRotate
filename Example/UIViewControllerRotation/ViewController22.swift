//
//  ViewController22.swift
//  UIViewControllerRotation_Example
//
//  Created by Kagen Zhao on 2020/7/28.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class ViewController22: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @IBAction func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
}
