//
//  RepositorySettingsViewController.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit
import WidgetKit

import GitodoShared

import RxSwift
import SwiftyToaster

final class RepositorySettingsViewController: BaseViewController<RepositorySettingsView>, BaseViewControllerProtocol, UIGestureRecognizerDelegate {
    
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
        setNavigationBarBackground(.secondarySystemBackground)
        setTitle("레포지토리 관리")
        if UserDefaultsManager.isPublicRepoSet {
            setLeftBackButton()
            setRightButton(symbolName: "plus")
            setRightButtonAction(#selector(handlePlusButtonTap))
        } else {
            setRightButton(title: "완료")
            setRightButtonAction(#selector(popViewControllerIf))
        }
        
    }
    
    @objc private func popViewControllerIf() {
        if UserDefaultsManager.isPublicRepoSet {
            navigationController?.popViewController(animated: true)
        } else {
            Toaster.shared.makeToast("한 개 이상의 레포지토리를 선택해야 합니다.")
        }
    }
    
    @objc private func handlePlusButtonTap() {
        navigationController?.pushViewController(OrganizationViewController(), animated: true)
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
        UserDefaultsManager.isPublicRepoSet = false
        WidgetCenter.shared.reloadAllTimelines()
        
        guard let window = view.window else { return }
        DispatchQueue.main.async {
            window.rootViewController = LoginViewController()
            Toaster.shared.makeToast("토큰이 만료됐습니다.\n다시 로그인해주세요.")
        }
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.output.myRepos
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
        let viewController = MyRepoInfoViewController(viewModel: MyRepoInfoViewModel(repository: repository))
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
}

extension RepositorySettingsViewController: MyRepoInfoViewControllerDelegate {
    
    func doneButtonTapped(repository: MyRepo) {
        viewModel.input.updateRepoInfo.onNext(repository)
    }
    
}

