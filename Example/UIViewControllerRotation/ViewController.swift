//
//  ViewController.swift
//  UIViewControllerRotation
//
//  Created by kagenZhao on 10/22/2018.
//  Copyright (c) 2018 kagenZhao. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("NavigationController 创建了")
    }
    
    deinit {
        print("NavigationController 销毁了")
    }
}


class SubViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SubViewController 创建了")
        view.backgroundColor = .white
        let btn = UIButton(type: .system)
        btn.frame = CGRect(x: 10, y: 200, width: 100, height: 100)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(back), for: .touchUpInside)
        view.addSubview(btn)
    }
    
    @objc func back() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("SubViewController 销毁了")
    }
}



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
//        navigationController?.popToViewController(self.navigationController!.viewControllers[1], animated: true)
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func presentNavi() {
        let navi = NavigationController(rootViewController: SubViewController())
        navi.modalPresentationStyle = .fullScreen
        present(navi, animated: true, completion: nil)
    }
    
    deinit {
        print("\(type(of: self)) 已经销毁了")
    }
}

