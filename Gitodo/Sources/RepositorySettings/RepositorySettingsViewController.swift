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
    }
    
    func setupNavigationBar() {
        setTitle("레포지토리 설정")
        setLeftBackButton()
    }
    
}
