//
//  ViewController.swift
//  KKSandboxUI
//
//  Created by 王铁山 on 2019/12/11.
//  Copyright © 2019 onety. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "KKSandboxUIDemo"
        view.backgroundColor = .white
        let btn = UIButton.init(type: .system)
        btn.setTitle("查看沙盒文件", for: .normal)
        btn.addTarget(self, action: #selector(sandBox), for: .touchUpInside)
        view.addSubview(btn)
        btn.sizeToFit()
        btn.center = CGPoint(x: view.frame.size.width / 2.0, y: view.frame.size.height / 2.0)
    }

    @objc func sandBox() {
        let vc = KKSandboxUIViewController.init(rootPath: NSHomeDirectory() + "/Library", component: nil)
        self.navigationController?.present(UINavigationController.init(rootViewController: vc), animated: true, completion: nil)
    }

}

