//
//  IssueView.swift
//  Gitodo
//
//  Created by jiyeon on 5/3/24.
//

import UIKit

import GitodoShared

import RxCocoa
import RxSwift
import SnapKit

protocol IssueDelegate: AnyObject {
    func presentInfoViewController(issue: Issue)
}

final class IssueView: LoadableView {
    
    weak var issueDelegate: IssueDelegate?
    private var viewModel: IssueViewModel?
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private lazy var issueTableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .background
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(cellType: IssueCell.self)
        return tableView
    }()
    
    private lazy var messageLabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .bodySB
        label.textColor = .tertiaryLabel
        return label
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .background
        setupLayout()
        setupNotificationCenterObserver()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        addSubview(issueTableView)
        issueTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-45)
        }
        
        bringSubviewToFront(loadingView)
    }
    
    private func setupNotificationCenterObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHeightChange),
            name: .AssigneeCollectionViewHeightDidUpdate,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHeightChange),
            name: .LabelCollectionViewHeightDidUpdate,
            object: nil
        )
    }
    
    @objc private func handleHeightChange(notification: Notification) {
        UIView.performWithoutAnimation { [weak self] in
            self?.issueTableView.beginUpdates()
            self?.issueTableView.endUpdates()
        }
    }
    
    private func bind() {
        issueTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self, let viewModel = viewModel else { return }
                issueDelegate?.presentInfoViewController(issue: viewModel.issue(at: indexPath))
            }).disposed(by: disposeBag)
    }
    
    func bind(with viewModel: IssueViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.issues
            .drive(issueTableView.rx.items(
                cellIdentifier: IssueCell.reuseIdentifier,
                cellType: IssueCell.self)
            ) { _, issue, cell in
                cell.configure(with: issue)
            }.disposed(by: disposeBag)
        
        viewModel.output.issueState
            .drive(onNext: { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .hasIssues:
                    messageLabel.isHidden = true
                default:
                    showMessageLabel(with: state.message)
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.isLoading
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            }).disposed(by: disposeBag)
    }
    
    private func showMessageLabel(with text: String?) {
        messageLabel.text = text
        messageLabel.isHidden = false
    }
    
}
