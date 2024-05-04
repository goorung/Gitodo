//
//  IssueInfoView.swift
//  Gitodo
//
//  Created by jiyeon on 5/4/24.
//

import UIKit

import SnapKit

class IssueInfoView: UIView {
    
    private let insetFromSuperView: CGFloat = 20.0
    private let offsetFromOtherView: CGFloat = 20.0
    private let offsetFromFriendView: CGFloat = 10.0
    
    // MARK: - UI Components
    
    private lazy var scrollView = UIScrollView()
    
    private lazy var contentView = UIView()
    
    private lazy var titleLabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 20.0)
        label.textColor = .label
        return label
    }()
    
    private lazy var labelsLabel = createLabel(withText: "Labels")
    
    private lazy var labelsView = LabelCollectionView()
    
    private lazy var assigneesLabel = createLabel(withText: "Assignees")
    
    private lazy var assigneesView = AssigneesView()
    
    private lazy var bodyContainerView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.systemGray3.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private lazy var bodyLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15.0)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Intiaizlier
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        NotificationCenter.default.addObserver(self, selector: #selector(handleHeightChange), name: NSNotification.Name("LabelCollectionViewHeightUpdated"), object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleHeightChange(notification: Notification) {
        guard notification.object is LabelCollectionView else { return }
        layoutIfNeeded()
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.snp.width)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(insetFromSuperView)
        }
        
        contentView.addSubview(labelsLabel)
        labelsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(offsetFromOtherView)
            make.leading.equalToSuperview().inset(insetFromSuperView)
        }
        
        contentView.addSubview(labelsView)
        labelsView.snp.makeConstraints { make in
            make.top.equalTo(labelsLabel.snp.bottom).offset(offsetFromFriendView)
            make.leading.trailing.equalToSuperview().inset(insetFromSuperView)
        }
        
        contentView.addSubview(assigneesLabel)
        assigneesLabel.snp.makeConstraints { make in
            make.top.equalTo(labelsView.snp.bottom).offset(offsetFromOtherView)
            make.leading.equalToSuperview().inset(insetFromSuperView)
        }
        
        contentView.addSubview(assigneesView)
        assigneesView.snp.makeConstraints { make in
            make.top.equalTo(assigneesLabel.snp.bottom).offset(offsetFromFriendView)
            make.leading.trailing.equalToSuperview().inset(insetFromSuperView)
        }
        
        contentView.addSubview(bodyContainerView)
        bodyContainerView.snp.makeConstraints { make in
            make.top.equalTo(assigneesView.snp.bottom).offset(offsetFromOtherView)
            make.leading.trailing.equalToSuperview().inset(insetFromSuperView)
            make.bottom.lessThanOrEqualToSuperview().inset(insetFromSuperView * 2)
        }
        
        bodyContainerView.addSubview(bodyLabel)
        bodyLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(insetFromSuperView)
        }
    }
    
    func configure(with issue: Issue?) {
        guard let issue = issue else { return }
        titleLabel.text = issue.title
        labelsView.configure(with: issue.labels)
        assigneesView.configure(with: issue.assignees)
        bodyLabel.text = issue.body
    }
    
}

extension IssueInfoView {
    
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        return label
    }
    
}
