//
//  ViewController2.swift
//  UIViewControllerRotation
//
//  Created by kagenZhao on 10/22/2018.
//  Copyright (c) 2018 kagenZhao. All rights reserved.
//

import UIKit

class ViewController1: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeLeft
    }
    
    @IBAction func popRoot() {
//        navigationController?.popToViewController(self.navigationController!.viewControllers[1], animated: true)
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func popself() {
//        navigationController?.popToViewController(self.navigationController!.viewControllers[1], animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dismissself() {
//        navigationController?.popToViewController(self.navigationController!.viewControllers[1], animated: true)
        (tabBarController ?? navigationController ?? self).dismiss(animated: true, completion: nil)
    }
    

    @IBAction func showAlert() {
        let alert = UIAlertController(title: "title", message: "message", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "好", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func presentNavi() {
        let vc = SuperViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    deinit {
        print("\(type(of: self)) 已经销毁了")
    }
}
