//
//  DeletionOptionViewController.swift
//  GitodoShared
//
//  Created by 이지현 on 7/23/24.
//

import UIKit

import SnapKit

class DeletionOptionViewController: BaseViewController<DeletionOptionView>, BaseViewControllerProtocol, UIGestureRecognizerDelegate {
    
//    init(viewModel: MyRepoInfoViewModel?) {
//        self.viewModel = viewModel
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        setTitle("완료된 할 일 삭제")
        setLeftBackButton()
    }

}
