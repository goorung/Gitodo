//
//  AssigneesView.swift
//  Gitodo
//
//  Created by jiyeon on 5/3/24.
//

import UIKit

import SnapKit

class AssigneesView: UIView {
    
    // MARK: - UI Components
    
    private lazy var personImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = .systemGray
        return imageView
    }()
    
    private lazy var assigneesLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13.0)
        label.textColor = .systemGray
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        addSubview(personImageView)
        personImageView.snp.makeConstraints { make in
            make.width.height.equalTo(18)
            make.top.leading.equalToSuperview()
        }
        
        addSubview(assigneesLabel)
        assigneesLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(1)
            make.trailing.bottom.equalToSuperview()
            make.leading.equalTo(personImageView.snp.trailing).offset(5)
        }
    }
    
    func configure(with assignees: [Assignee]?) {
        guard let assignees = assignees else { return }
        assigneesLabel.text = assignees.map { $0.login }.joined(separator: " ")
    }
    
}
