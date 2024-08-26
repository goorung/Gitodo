//
//  DeletionOptionViewController.swift
//  GitodoShared
//
//  Created by 이지현 on 7/23/24.
//

import UIKit

import GitodoShared

import SnapKit

protocol DeletionOptionViewControllerDelegate: AnyObject {
    func updateDeletionOption()
}

class DeletionOptionViewController: BaseViewController<DeletionOptionView>, BaseViewControllerProtocol, UIGestureRecognizerDelegate {
    
    weak var delegate: DeletionOptionViewControllerDelegate?

    init(myRepoInfoViewModel: MyRepoInfoViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        contentView.viewModel = myRepoInfoViewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        setupNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.updateDeletionOption()
    }
    
    func setupNavigationBar() {
        setTitle("완료된 할 일 삭제")
        setLeftBackButton()
    }

}
