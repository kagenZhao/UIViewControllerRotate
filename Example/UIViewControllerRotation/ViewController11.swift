//
//  ViewController11.swift
//  UIViewControllerRotation_Example
//
//  Created by Kagen Zhao on 2020/7/28.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class ViewController11: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func goback(_ sender: Any) {
        self.tabBarController?.dismiss(animated: true, completion: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

}
