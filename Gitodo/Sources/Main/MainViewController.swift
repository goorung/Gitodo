//
//  MainViewController.swift
//  Gitodo
//
//  Created by 이지현 on 4/25/24.
//

import UIKit

class MainViewController: BaseViewController<MainView>, BaseViewControllerProtocol {

    private let viewModel: MainViewModel
    
    // MARK: - Initializer
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        hideKeyboardWhenTappedAround()
        setupNotificationCenterObserver()
        
        contentView.bind(with: viewModel)
        contentView.setIssueDelegate(self)
        
        pushRepositorySettingViewControllerIf()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.input.viewWillAppear.onNext(())
    }
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        contentView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Navigation Bar
    
    func setupNavigationBar() {
        setTitle("Gitodo",at: .left, font: .systemFont(ofSize: 20, weight: .bold))
        Task {
            do {
                let me = try await APIManager.shared.fetchMe()
                DispatchQueue.main.async {
                    self.setProfileImageView(url: URL(string:me.avatarUrl))
                }
            } catch {
                print("실패: \(error.localizedDescription)")
            }
        }
        setProfileImageViewAction(#selector(handleProfileImageViewTap))
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
        viewModel.input.viewWillAppear.onNext(())
    }
    
    @objc private func handleAccessTokenExpire() {
        UserDefaultsManager.isLogin = false
        guard let window = view.window else { return }
        window.rootViewController = LoginViewController()
    }
    
    private func pushRepositorySettingViewControllerIf() {
        if UserDefaultsManager.isPublicRepoSet == false {
            let repositorySettingsViewController = RepositorySettingsViewController()
            navigationController?.pushViewController(repositorySettingsViewController, animated: true)
        }
    }
    
}

extension MainViewController: MenuDelegate, RepoMenuDelegate {
    func pushViewController(_ menu: MenuType) {
        switch menu {
        case .repositorySettings:
            let repositorySettingsViewController = RepositorySettingsViewController()
            navigationController?.pushViewController(repositorySettingsViewController, animated: true)
        case .contact:
            print("문의하기")
        case .logout:
            presentAlertViewController()
        }
    }
    
    private func presentAlertViewController() {
        let alertController = UIAlertController(
            title: "",
            preferredStyle: .alert
            message: "모든 설정 및 할 일이 삭제됩니다.",
        )
        
        let deleteAction = UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            // 모든 레포지토리 삭제
            self?.viewModel.input.resetAllRepository.onNext(())
            // 액세스 토큰 삭제 및 설정 초기화
            LoginManager.shared.deleteAccessToken()
            UserDefaultsManager.isLogin = false
            UserDefaultsManager.isFirst = true
            // 화면 이동
            let loginViewController = LoginViewController()
            self?.view.window?.rootViewController = UINavigationController(rootViewController: loginViewController)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    func pushViewController(_ repoMenu: RepoMenuType, _ repo: MyRepo) {
        switch repoMenu {
        case .edit:
            presentRepoInfoViewController(repo)
        case .hide:
            viewModel.input.hideRepo.onNext(repo)
        }
    }
    
    private func presentRepoInfoViewController(_ repo: MyRepo) {
        let viewController = RepositoryInfoViewController(viewModel: RepositoryInfoViewModel(repository: repo))
        viewController.delegate = self
        present(viewController, animated: true)
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

extension MainViewController: MainViewDelegate {
    func showMenu(from cell: RepositoryInfoCell) {
        guard let repo = cell.repository else { return }
        let menuViewController = RepoMenuViewController(repo: repo)
        menuViewController.delegate = self
        menuViewController.modalPresentationStyle = .popover
        
        if let popoverController = menuViewController.popoverPresentationController {
            popoverController.sourceView = cell
            popoverController.sourceRect = CGRect(x: cell.bounds.midX, y: cell.bounds.maxY + 5, width: 0, height: 0)
            popoverController.permittedArrowDirections = .up
            popoverController.delegate = self
        }
        
        present(menuViewController, animated: true)
    }
    
}

extension MainViewController: RepositoryInfoViewControllerDelegate {
    func doneButtonTapped(repository: MyRepo) {
        viewModel.input.updateRepoInfo.onNext(repository)
    }
    
}
