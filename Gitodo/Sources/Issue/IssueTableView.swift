//
//  IssueTableView.swift
//  Gitodo
//
//  Created by jiyeon on 5/3/24.
//

import UIKit

import RxCocoa
import RxSwift

protocol IssueDelegate: AnyObject {
    func presentInfoViewController(issue: Issue)
}

class IssueTableView: UITableView {
    
    weak var issueDelegate: IssueDelegate?
    private var viewModel: IssueViewModel?
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        setupProperty()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    
    private func setupProperty() {
        rowHeight = UITableView.automaticDimension
        register(IssueCell.self, forCellReuseIdentifier: IssueCell.reuseIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleHeightChange), name: .AssigneeCollectionViewHeightDidUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleHeightChange), name: .LabelCollectionViewHeightDidUpdate, object: nil)
    }
    
    @objc private func handleHeightChange(notification: Notification) {
        UIView.performWithoutAnimation { [weak self] in
            self?.beginUpdates()
            self?.endUpdates()
        }
    }
    
    private func bind() {
        self.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self, let viewModel = viewModel else { return }
                issueDelegate?.presentInfoViewController(issue: viewModel.issue(at: indexPath))
            }).disposed(by: disposeBag)
    }
    
    func bind(with viewModel: IssueViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.issues
            .drive(self.rx.items(cellIdentifier: IssueCell.reuseIdentifier, cellType: IssueCell.self)) { _, issue, cell in
                cell.configure(with: issue)
            }.disposed(by: disposeBag)
    }
    
}
