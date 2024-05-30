//
//  LoginViewController.swift
//  Gitodo
//
//  Created by jiyeon on 5/6/24.
//

import SafariServices
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
            name: .AccessTokenFetchDidStart,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLoginEnd),
            name: .AccessTokenFetchDidEnd,
            object: nil
        )
    }
    
    @objc private func handleLoginStart() {
        contentView.startLoading()
    }
    
    @objc private func handleLoginEnd() {
        contentView.endLoading()
        DispatchQueue.main.async {
            let mainViewModel = MainViewModel(localRepositoryService: LocalRepositoryService())
            let mainViewController = MainViewController(viewModel: mainViewModel)
            self.view.window?.rootViewController = UINavigationController(rootViewController: mainViewController)
        }
    }
    
}

extension LoginViewController: LoginDelegate {
    
    func loginWithGithub() {
        present(AuthViewController(), animated: true)
    }
    
}
