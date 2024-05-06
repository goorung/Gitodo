//
//  IssueInfoViewController.swift
//  Gitodo
//
//  Created by jiyeon on 5/4/24.
//

import UIKit

class IssueInfoViewController: BaseViewController<IssueInfoView>, BaseViewControllerProtocol {
    
    var issue: Issue? {
        didSet {
            contentView.configure(with: issue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        setRightButton(title: "닫기")
        setRightButtonAction(#selector(handleCloseButtonTap))
    }
    
    @objc private func handleCloseButtonTap(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
