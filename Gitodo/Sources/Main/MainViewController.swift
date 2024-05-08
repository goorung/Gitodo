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
        hideKeyboardWhenTappedAround()
        contentView.setIssueDelegate(self)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRepoOrderChange), name: .RepositoryOrderDidUpdate, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        contentView.viewModel.input.viewWillAppear.onNext(())
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupNavigationBar() {
        setTitle("Gitodo",at: .left, font: .systemFont(ofSize: 20, weight: .bold))
        setProfileImageView(image: nil)
        setProfileImageViewAction(#selector(handleProfileImageViewTap))
        remakeConstraintWithKeyboardLayoutGuide()
    }
    
    @objc private func handleProfileImageViewTap(_ gesture: UITapGestureRecognizer) {
        guard let imageView = gesture.view as? SymbolCircleView else { return }
        
        let menuViewController = MenuViewController()
        menuViewController.delegate = self
        menuViewController.modalPresentationStyle = .popover
        
        if let popoverController = menuViewController.popoverPresentationController {
            popoverController.sourceView = imageView
            popoverController.sourceRect = CGRect(x: imageView.bounds.midX, y: imageView.bounds.midY + 100, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
            popoverController.delegate = self
        }
        
        present(menuViewController, animated: true)
    }
    
    @objc private func handleRepoOrderChange() {
        contentView.viewModel.input.viewWillAppear.onNext(())
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

extension MainViewController: IssueDelegate {
    
    func presentInfoViewController(issue: Issue) {
        let issueInfoViewController = IssueInfoViewController()
        issueInfoViewController.issue = issue
        present(issueInfoViewController, animated: true)
    }
    
}
