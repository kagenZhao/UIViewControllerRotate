//
//  ViewController.swift
//  UIViewControllerRotation
//
//  Created by kagenZhao on 10/22/2018.
//  Copyright (c) 2018 kagenZhao. All rights reserved.
//

import UIKit
import UIViewControllerRotation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    @IBAction func gobackRoot() {
        navigationController?.popToViewController(self.navigationController!.viewControllers[1], animated: true)
        //        navigationController?.popToRootViewController(animated: true)
    }
}

