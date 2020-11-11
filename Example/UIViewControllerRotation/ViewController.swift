//
//  ViewController.swift
//  UIViewControllerRotation
//
//  Created by kagenZhao on 10/22/2018.
//  Copyright (c) 2018 kagenZhao. All rights reserved.
//

import UIKit


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
    
    @IBAction func presentNavi() {
        let vc = SuperViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func showAlert() {
        let alert = UIAlertController(title: "title", message: "message", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "好", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func testStatusBar() {
        if let vc = UIStoryboard.init(name: "Main2", bundle: Bundle.main).instantiateInitialViewController() {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    deinit {
        print("\(type(of: self)) 已经销毁了")
    }
}



class SuperViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
        
        let button = UIButton(type: .system)
        button.setTitle("dismiss", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        button.frame = CGRect(x: 50, y: 100, width: 100, height: 50)
        self.view.addSubview(button)
    }
    
    override var shouldAutorotate: Bool {
//        return presentingViewController!.shouldAutorotate
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return presentingViewController!.supportedInterfaceOrientations
        return .landscapeLeft
    }
    
    @objc func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
}

