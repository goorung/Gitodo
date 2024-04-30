//
//  RepositoryInfoViewController.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit

class RepositoryInfoViewController: BaseViewController<RepositoryInfoView>, BaseViewControllerProtocol {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        setTitle("레포지토리 정보")
        setLeftButton(title: "취소")
        setLeftButtonAction(#selector(handleCancelButtonTap))
        setRightButton(title: "완료")
        setRightButtonAction(#selector(handleDoneButtonTap))
    }
    
    @objc private func handleCancelButtonTap(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc private func handleDoneButtonTap(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
