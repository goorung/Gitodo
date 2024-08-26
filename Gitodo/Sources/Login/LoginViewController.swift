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
            selector: #selector(handleAccessTokenFetchDidStart),
            name: .AccessTokenFetchDidStart,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAccessTokenFetchDidEnd),
            name: .AccessTokenFetchDidEnd,
            object: nil
        )
    }
    
    @objc private func handleAccessTokenFetchDidStart() {
        contentView.startLoading()
    }
    
    @objc private func handleAccessTokenFetchDidEnd() {
        contentView.endLoading()
        DispatchQueue.main.async {
            let mainViewModel = MainViewModel(localRepositoryService: LocalRepositoryService(), localTodoService: LocalTodoService())
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
