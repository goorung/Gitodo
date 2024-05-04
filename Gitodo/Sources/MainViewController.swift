//
//  MainViewController.swift
//  Gitodo
//
//  Created by 이지현 on 4/25/24.
//

import UIKit

class MainViewController: BaseViewController<MainView>, BaseViewControllerProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        setTitle("Gitodo",at: .left, font: .systemFont(ofSize: 20, weight: .bold))
        setProfileImageView(image: nil)
        setProfileImageViewAction(#selector(handleProfileImageViewTap))
    }
    
    @objc private func handleProfileImageViewTap(_ sender: UIImageView) {
        let menuViewController = MenuViewController()
        menuViewController.delegate = self
        menuViewController.modalPresentationStyle = .popover
        
        if let popoverController = menuViewController.popoverPresentationController {
            popoverController.sourceView = profileImageView
            popoverController.sourceRect = CGRect(x: profileImageView.bounds.midX, y: profileImageView.bounds.midY + 100, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
            popoverController.delegate = self
        }
        
        present(menuViewController, animated: true)
    }
    
}

extension MainViewController: MenuDelegate {
    
    func pushViewController(_ menu: MenuType) {
        switch menu {
        case .repositorySettings:
            let repositorySettingsViewController = RepositorySettingsViewController()
            navigationController?.pushViewController(repositorySettingsViewController, animated: true)
        case .contact:
            print("문의하기")
        case .logout:
            print("로그아웃")
        }
    }
    
}

extension MainViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}
