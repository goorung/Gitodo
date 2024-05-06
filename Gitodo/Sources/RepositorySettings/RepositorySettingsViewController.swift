//
//  RepositorySettingsViewController.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit

class RepositorySettingsViewController: BaseViewController<RepositorySettingsView>, BaseViewControllerProtocol {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        contentView.delegate = self
    }
    
    func setupNavigationBar() {
        setTitle("레포지토리 설정")
        setLeftBackButton()
    }
    
}

extension RepositorySettingsViewController: RepositorySettingsDelegate {
    func presentRepositoryInfoViewController() {
        present(RepositoryInfoViewController(), animated: true)
    }
    
    
    func presentAlertViewController(completion: @escaping (() -> Void)) {
        let alertController = UIAlertController(
            title: "레포지토리 삭제",
            message: "정말로 삭제하시겠습니까?\n모든 할 일이 함께 삭제됩니다.",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            completion()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
}
