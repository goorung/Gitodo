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
        contentView.viewModel.input.viewDidLoad.onNext(())
        NotificationCenter.default.addObserver(self, selector: #selector(handleRepoOrderChange), name: .RepositoryOrderDidUpdate, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupNavigationBar() {
        setTitle("레포지토리 설정")
        setLeftBackButton()
    }
    
    @objc private func handleRepoOrderChange() {
        contentView.viewModel.input.viewDidLoad.onNext(())
    }
    
}

extension RepositorySettingsViewController: RepositorySettingsDelegate {
    func presentRepositoryInfoViewController(repository: Repository) {
        let viewController = RepositoryInfoViewController(viewModel: RepositoryInfoViewModel(repository: repository))
        viewController.delegate = self
        present(viewController, animated: true)
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

extension RepositorySettingsViewController: RepositoryInfoViewControllerDelegate {
    func doneButtonTapped(repository: Repository) {
        contentView.viewModel.input.updateRepo.onNext(repository)
    }
    
}
