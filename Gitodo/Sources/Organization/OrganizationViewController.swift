//
//  OrganizationViewController.swift
//  Gitodo
//
//  Created by 지연 on 7/9/24.
//

import UIKit

final class OrganizationViewController: BaseViewController<OrganizationView>, BaseViewControllerProtocol {
    private let viewModel = OrganizationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        contentView.bind(with: viewModel)
        viewModel.input.viewDidLoad.onNext(())
    }
    
    func setupNavigationBar() {
        setTitle("조직")
        setNavigationBarBackground(.secondarySystemBackground)
        setLeftBackButton()
    }
    
    
}
