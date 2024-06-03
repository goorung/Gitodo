//
//  IssueInfoViewController.swift
//  Gitodo
//
//  Created by jiyeon on 5/4/24.
//

import UIKit

import GitodoShared

final class IssueInfoViewController: BaseViewController<IssueInfoView>, BaseViewControllerProtocol {
    
    var issue: Issue? {
        didSet {
            contentView.configure(with: issue)
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
    }
    
    // MARK: - Setup Navigation Bar
    
    func setupNavigationBar() {
        setRightButton(title: "닫기")
        setRightButtonAction(#selector(handleCloseButtonTap))
    }
    
    @objc private func handleCloseButtonTap(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
