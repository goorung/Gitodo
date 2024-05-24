//
//  LoginViewController.swift
//  Gitodo
//
//  Created by jiyeon on 5/6/24.
//

import UIKit

final class LoginViewController: BaseViewController<LoginView> {
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotificationCenterObserver()
        contentView.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup NotificationCenter Observer
    
    private func setupNotificationCenterObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLoginStart),
            name: .LoginDidStart,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLoginEnd),
            name: .LoginDidEnd,
            object: nil
        )
    }
    
    @objc private func handleLoginStart() {
        contentView.startLoading()
    }
    
    @objc private func handleLoginEnd() {
        contentView.endLoading()
    }
    
}

extension LoginViewController: LoginDelegate {
    
    func loginWithGithub() {
        guard let url = LoginManager.shared.getLoginURL() else { return }
        UIApplication.shared.open(url)
    }
    
}
