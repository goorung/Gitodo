//
//  OrganizationView.swift
//  Gitodo
//
//  Created by 지연 on 7/9/24.
//

import UIKit

import GitodoShared

import RxCocoa
import RxSwift
import SnapKit

protocol OrganizationViewDelegate: AnyObject {
    func pushRepositoryViewController(for: Organization, type: RepositoryFetchType)
}

final class OrganizationView: LoadableView {
    
    weak var delegate: OrganizationViewDelegate?
    private weak var viewModel: OrganizationViewModel?
    private let disposeBag = DisposeBag()
    
    private let heightForRow: CGFloat = 60.0
    private var organizationTableViewHeightConstraint: Constraint?
    
    // MARK: - UI Components
    
    private lazy var scrollView = UIScrollView()
    
    private lazy var contentView = UIView()
    
    private lazy var organizationTableView = {
        let tableView = UITableView()
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.rowHeight = heightForRow
        tableView.backgroundColor = .background
        tableView.isScrollEnabled = false
        tableView.register(cellType: OrganizationCell.self)
        return tableView
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .secondarySystemBackground
        loadingView.backgroundColor = .secondarySystemBackground
        setupLayout()
        bind()
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
        
        contentView.addSubview(organizationTableView)
        organizationTableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            self.organizationTableViewHeightConstraint = make.height.equalTo(0).constraint
            make.bottom.equalToSuperview()
        }
        
        bringSubviewToFront(loadingView)
    }
    
    // MARK: - Bind
    
    func bind() {
        organizationTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self, let viewModel else { return }
                let owner = viewModel.getRepositoryOwner(at: indexPath)
                let type: RepositoryFetchType = indexPath.row == 0 ? .user : .organization
                delegate?.pushRepositoryViewController(for: owner, type: type)
            }).disposed(by: disposeBag)
        
        scrollView.rx.didScroll
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                if scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.bounds.size.height) {
                    viewModel?.input.fetchMoreOrganizations.onNext(())
                }
            }).disposed(by: disposeBag)
    }
    
    func bind(with viewModel: OrganizationViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.organizations
            .do(onNext: { [weak self] organizations in
                guard let self = self else { return }
                let height = CGFloat(organizations.count) * heightForRow
                organizationTableViewHeightConstraint?.update(offset: height)
                organizationTableView.layoutIfNeeded() // 즉시 레이아웃 업데이트
            })
            .drive(organizationTableView.rx.items(
                cellIdentifier: OrganizationCell.reuseIdentifier,
                cellType: OrganizationCell.self)
            ) { _, organization, cell in
                cell.configure(with: organization)
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
