//
//  OrganizationView.swift
//  Gitodo
//
//  Created by 지연 on 7/9/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class OrganizationView: UIView {
    
    private var viewModel: OrganizationViewModel?
    private let disposeBag = DisposeBag()
    private var organizationTableViewHeightConstraint: Constraint?
    
    // MARK: - UI Components
    
    private lazy var organizationTableView = {
        let tableView = UITableView()
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.rowHeight = 60
        tableView.register(cellType: OrganizationCell.self)
        return tableView
    }()
    
    private lazy var loadingView = {
        let view = UIView()
        view.backgroundColor = .background
        return view
    }()
    
    private lazy var loadingIndicator = UIActivityIndicatorView()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .secondarySystemBackground
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        addSubview(organizationTableView)
        organizationTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingView.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-45)
        }
    }
    
    // MARK: - Bind
    
    func bind(with viewModel: OrganizationViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.organizations
            .drive(organizationTableView.rx.items(
                cellIdentifier: OrganizationCell.reuseIdentifier,
                cellType: OrganizationCell.self)
            ) { _, organization, cell in
                cell.configure(with: organization)
            }.disposed(by: disposeBag)
        
        viewModel.output.isLoading
            .drive(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    loadingView.isHidden = false
                    loadingIndicator.startAnimating()
                } else {
                    DispatchQueue.main.async {
                        self.loadingIndicator.stopAnimating()
                        self.loadingView.isHidden = true
                    }
                }
            }).disposed(by: disposeBag)
    }
}
