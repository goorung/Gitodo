//
//  OrganizationViewController.swift
//  Gitodo
//
//  Created by 지연 on 7/9/24.
//

import UIKit

import GitodoShared

final class OrganizationViewController: BaseViewController<OrganizationView>, BaseViewControllerProtocol {
    
    private let viewModel = OrganizationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        contentView.delegate = self
        contentView.bind(with: viewModel)
        viewModel.input.fetchOrganizations.onNext(())
    }
    
    func setupNavigationBar() {
        setTitle("조직")
        setNavigationBarBackground(.secondarySystemBackground)
        setLeftBackButton()
    }
    
}

extension OrganizationViewController: OrganizationViewDelegate {
    
    func pushRepositoryViewController(for owner: Organization, type: RepositoryFetchType) {
        let repositoryViewModel = RepositoryViewModel(
            for: owner,
            type: type,
            service: LocalRepositoryService()
        )
        let repositoryViewController = RepositoryViewController(viewModel: repositoryViewModel)
        navigationController?.pushViewController(repositoryViewController, animated: true)
    }
    
}
