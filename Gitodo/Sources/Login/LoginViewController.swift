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
        guard let url = LoginManager.shared.getLoginURL() else { return }
        UIApplication.shared.open(url)
    }
    
}
