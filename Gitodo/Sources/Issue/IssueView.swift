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

class IssueView: UIView {
    
    weak var issueDelegate: IssueDelegate?
    private var viewModel: IssueViewModel?
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private lazy var issueTableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(IssueCell.self, forCellReuseIdentifier: IssueCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var messageLabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .tertiaryLabel
        return label
    }()
    
    private lazy var loadingView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var loadingIndicator = UIActivityIndicatorView()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
            .map { $0.count }
            .drive(onNext: { [weak self] count in
                guard let self = self else { return }
                if count == 0 {
                    showMessageLabel(with: "생성된 이슈가 없습니다 🫥")
                } else {
                    messageLabel.isHidden = true
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.issues
            .drive(issueTableView.rx.items(
                cellIdentifier: IssueCell.reuseIdentifier,
                cellType: IssueCell.self)
            ) { _, issue, cell in
                cell.configure(with: issue)
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
        
        viewModel.output.isDeleted
            .filter { $0 == true }
            .drive(onNext: { [weak self] _ in
                self?.showMessageLabel(with: "원격에서 삭제된 레포지토리입니다 👻")
            }).disposed(by: disposeBag)
    }
    
    private func showMessageLabel(with text: String?) {
        messageLabel.text = text
        messageLabel.isHidden = false
    }
    
}
