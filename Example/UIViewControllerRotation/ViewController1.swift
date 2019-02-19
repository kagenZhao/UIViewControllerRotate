//
//  ViewController1.swift
//  UIViewControllerRotation_Example
//
//  Created by 赵国庆 on 2018/10/22.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class ViewController1: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
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
//        navigationController?.popToViewController(self.navigationController!.viewControllers[1], animated: true)
        navigationController?.popToRootViewController(animated: true)
    }
    
    deinit {
        print("\(type(of: self)) 已经销毁了")
    }
}
