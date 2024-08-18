//
//  MyRepoInfoViewController.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit

import GitodoShared

protocol MyRepoInfoViewControllerDelegate: AnyObject {
    func doneButtonTapped(repository: MyRepo)
}

final class MyRepoInfoViewController: BaseViewController<MyRepoInfoView>, BaseViewControllerProtocol {
    
    weak var delegate: MyRepoInfoViewControllerDelegate?
    private var viewModel: MyRepoInfoViewModel?
    
    // MARK: - Initializer
    
    init(viewModel: MyRepoInfoViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
        contentView.bind(with: viewModel)
        contentView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
    }
    
    // MARK: - Setup Navigation Bar
    
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
        guard let repository = viewModel?.repository else { return }
        delegate?.doneButtonTapped(repository: repository)
        dismiss(animated: true)
    }
    
}

extension MyRepoInfoViewController: MyRepoInfoViewDelegate {
    func pushDeletionOptionViewController() {
        guard let viewModel else { return }
        navigationController?.pushViewController(DeletionOptionViewController(myRepoInfoViewModel: viewModel), animated: true)
    }
    
}
