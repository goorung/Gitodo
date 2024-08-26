//
//  RepositoryViewController.swift
//  Gitodo
//
//  Created by 지연 on 7/10/24.
//

import UIKit

final class RepositoryViewController: BaseViewController<RepositoryView>, BaseViewControllerProtocol {
    
    private let viewModel: RepositoryViewModel
    
    // MARK: - Life Cycle
    
    init(viewModel: RepositoryViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        contentView.bind(with: viewModel)
        viewModel.input.fetchRepositories.onNext(())
    }
    
    func setupNavigationBar() {
        setTitle("레포지토리")
        setNavigationBarBackground(.secondarySystemBackground)
        setLeftBackButton()
    }
    
    
}
