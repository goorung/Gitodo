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
        contentView.setIssueDelegate(self)
    }
    
    func setupNavigationBar() {
        setTitle("Gitodo",at: .left, font: .systemFont(ofSize: 20, weight: .bold))
        setRightButton(symbolName: "person.crop.circle")
        
        let repositoryInfoAction = UIAction(title: "레포지토리 정보") { [weak self] _ in
            guard let self = self else { return }
            let repositoryInfoViewController = RepositoryInfoViewController()
            present(repositoryInfoViewController, animated: true)
        }
        let repositorySettingsAction = UIAction(title: "레포지토리 설정") { [weak self] _ in
            guard let self = self else { return }
            let repositorySettingsViewController = RepositorySettingsViewController()
            navigationController?.pushViewController(repositorySettingsViewController, animated: true)
        }
        let menu = UIMenu(title: "",
                          options: .displayInline,
                          children: [repositoryInfoAction, repositorySettingsAction])
        setRightButtonMenu(menu)
    }
    
}

extension MainViewController: IssueDelegate {
    
    func presentInfoViewController(issue: Issue) {
        let issueInfoViewController = IssueInfoViewController()
        issueInfoViewController.issue = issue
        present(issueInfoViewController, animated: true)
    }
    
}
