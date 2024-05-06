//
//  LoginViewController.swift
//  Gitodo
//
//  Created by jiyeon on 5/6/24.
//

import UIKit

class LoginViewController: BaseViewController<LoginView> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.delegate = self
    }
    
}

extension LoginViewController: LoginDelegate {
    
    func loginWithGithub() {
        changeRootViewController()
    }
    
    private func changeRootViewController() {
        guard let window = view.window else { return }
        window.rootViewController = UINavigationController(rootViewController: MainViewController())
    }
    
}
