//
//  DeletionOptionViewController.swift
//  GitodoShared
//
//  Created by 이지현 on 7/23/24.
//

import UIKit

import SnapKit

class DeletionOptionViewController: BaseViewController<DeletionOptionView>, BaseViewControllerProtocol, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        setupNavigationBar()
    }
    
    override func viewWillLayoutSubviews() {
        contentView.optionTableView.snp.makeConstraints { make in
            make.height.equalTo(contentView.optionTableView.contentSize.height + 210)
        }
    }
    
    func setupNavigationBar() {
        setTitle("완료된 할 일 삭제")
        setLeftBackButton()
    }

}
