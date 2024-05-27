//
//  IssueCell.swift
//  Gitodo
//
//  Created by jiyeon on 5/3/24.
//

import UIKit

import GitodoShared

import SnapKit

final class IssueCell: UITableViewCell {
    
    static let reuseIdentifier = "IssueCell"
    
    // MARK: - UI Components
    
    private lazy var stackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var titleLabel = {
        let label = UILabel()
        label.font = .bodySB
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var labelsView = LabelCollectionView()
    
    private lazy var assigneesView = AssigneeCollectionView()
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupProperty()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupProperty() {
        backgroundColor = .clear
        selectionStyle = .none
        clipsToBounds = true
        layer.cornerRadius = 15
    }
    
    private func setupLayout() {
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(labelsView)
        stackView.addArrangedSubview(assigneesView)
    }
    
    func configure(with issue: Issue?) {
        guard let issue = issue else { return }
        
        titleLabel.text = issue.title
        labelsView.configure(with: issue.labels)
        assigneesView.configure(with: issue.assignees)
    }
    
}
