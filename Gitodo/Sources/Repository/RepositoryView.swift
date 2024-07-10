//
//  RepositoryView.swift
//  Gitodo
//
//  Created by 지연 on 7/10/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class RepositoryView: LoadableView {
    
    private var viewModel: RepositoryViewModel?
    private let disposeBag = DisposeBag()
    
    private let heightForRow: CGFloat = 44.0
    private var repositoryTableViewHeightConstraint: Constraint?
    
    // MARK: - UI Components
    
    private lazy var scrollView = UIScrollView()
    
    private lazy var contentView = UIView()
    
    private lazy var repositoryTableView = {
        let tableView = UITableView()
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.rowHeight = heightForRow
        tableView.backgroundColor = .background
        tableView.isScrollEnabled = false
        tableView.register(cellType: RepositoryCell.self)
        return tableView
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .secondarySystemBackground
        loadingView.backgroundColor = .secondarySystemBackground
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.snp.width)
        }
        
        contentView.addSubview(repositoryTableView)
        repositoryTableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            self.repositoryTableViewHeightConstraint = make.height.equalTo(0).constraint
            make.bottom.equalToSuperview()
        }
        
        bringSubviewToFront(loadingView)
    }
    
    // MARK: - Bind
    
    func bind(with viewModel: RepositoryViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.repositories
            .do(onNext: { [weak self] repositories in
                guard let self = self else { return }
                let height = CGFloat(repositories.count) * heightForRow
                repositoryTableViewHeightConstraint?.update(offset: height)
                repositoryTableView.layoutIfNeeded() // 즉시 레이아웃 업데이트
            })
            .drive(repositoryTableView.rx.items(
                cellIdentifier: RepositoryCell.reuseIdentifier,
                cellType: RepositoryCell.self)
            ) { _, repositoryCellViewModel, cell in
                cell.configure(with: repositoryCellViewModel)
            }.disposed(by: disposeBag)
        
        viewModel.output.isLoading
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            }).disposed(by: disposeBag)
    }
    
}
