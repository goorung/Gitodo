//
//  RepositorySettingsViewController.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit

import RxSwift
import SwiftyToaster

class RepositorySettingsViewController: BaseViewController<RepositorySettingsView>, BaseViewControllerProtocol, UIGestureRecognizerDelegate {
    
    private let viewModel = RepositorySettingsViewModel(localRepositoryService: LocalRepositoryService())
    private let disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupNotificationCenterObserver()
        bind()
        
        contentView.delegate = self
        contentView.bind(with: viewModel)
        viewModel.input.fetchRepo.onNext(())
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Navigation Bar
    
    func setupNavigationBar() {
        setTitle("레포지토리 설정")
        setLeftButton(symbolName: "chevron.left")
        setLeftButtonAction(#selector(popViewControllerIf))
        setRightButton(symbolName: "arrow.clockwise")
        setRightButtonAction(#selector(fetchRepo))
    }
    
    @objc private func popViewControllerIf() {
        if UserDefaultsManager.isPublicRepoSet {
            navigationController?.popViewController(animated: true)
        } else {
            Toaster.shared.setToastType(.round)
            Toaster.shared.makeToast("한 개 이상의 레포지토리를 선택해야 합니다.")
        }
    }
    
    @objc private func fetchRepo() {
        viewModel.input.fetchRepo.onNext(())
    }
    
    // MARK: - Setup NotificationCenter Observer
    
    private func setupNotificationCenterObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRepoOrderChange),
            name: .RepositoryOrderDidUpdate,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAccessTokenExpire),
            name: .AccessTokenDidExpire,
            object: nil
        )
    }
    
    @objc private func handleRepoOrderChange() {
        viewModel.input.fetchRepo.onNext(())
    }
    
    @objc private func handleAccessTokenExpire() {
        UserDefaultsManager.isLogin = false
        guard let window = view.window else { return }
        DispatchQueue.main.async {
            window.rootViewController = LoginViewController()
            Toaster.shared.makeToast("토큰이 만료됐습니다.\n다시 로그인해주세요.")
        }
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.output.publicRepos
            .map { $0.count }
            .drive(onNext: { [weak self] count in
                guard let self = self else { return }
                if count > 0 {
                    UserDefaultsManager.isPublicRepoSet = true
                    navigationController?.interactivePopGestureRecognizer?.delegate = self
                    navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                } else {
                    UserDefaultsManager.isPublicRepoSet = false
                    navigationController?.interactivePopGestureRecognizer?.delegate = nil
                    navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                }
            }).disposed(by: disposeBag)
    }
    
}

extension RepositorySettingsViewController: RepositorySettingsDelegate {
    
    func presentRepositoryInfoViewController(repository: MyRepo) {
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
    
    func doneButtonTapped(repository: MyRepo) {
        viewModel.input.updateRepoInfo.onNext(repository)
    }
    
}

