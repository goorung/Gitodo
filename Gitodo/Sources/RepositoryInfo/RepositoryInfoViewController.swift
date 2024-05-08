//
//  RepositoryInfoViewController.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit

protocol RepositoryInfoViewControllerDelegate: AnyObject {
    func doneButtonTapped(repository: MyRepo)
}

class RepositoryInfoViewController: BaseViewController<RepositoryInfoView>, BaseViewControllerProtocol {
    weak var delegate: RepositoryInfoViewControllerDelegate?
    
    init(viewModel: RepositoryInfoViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        contentView.viewModel = viewModel
        contentView.initialConfigure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        guard let repository = contentView.viewModel?.repository else { return }
        delegate?.doneButtonTapped(repository: repository)
        dismiss(animated: true)
    }
    
}
