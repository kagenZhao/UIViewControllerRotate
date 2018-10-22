//
//  ViewController2.swift
//  UIViewControllerRotation_Example
//
//  Created by 赵国庆 on 2018/10/22.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class ViewController2: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeLeft
    }
    
    @IBAction func goback() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func gobackRoot() {
        navigationController?.popToRootViewController(animated: true)
    }
    
}
