//
//  RepositoryInfoViewController.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit

import GitodoShared

protocol RepositoryInfoViewControllerDelegate: AnyObject {
    func doneButtonTapped(repository: MyRepo)
}

final class RepositoryInfoViewController: BaseViewController<RepositoryInfoView>, BaseViewControllerProtocol {
    
    weak var delegate: RepositoryInfoViewControllerDelegate?
    private var viewModel: RepositoryInfoViewModel?
    
    // MARK: - Initializer
    
    init(viewModel: RepositoryInfoViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
        contentView.bind(with: viewModel)
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
