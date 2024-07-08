//
//  RepositoryCell.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit

import GitodoShared

import SnapKit

final class RepositoryCell: UITableViewCell {
    
    static let reuseIdentifier = "RepositoryCell"
    private var repo: MyRepo?
    
    // MARK: - UI Components
    
    private lazy var nameLabel = {
        let label = UILabel()
        label.font = .bodySB
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var moveButton = {
        let button = UIButton()
        button.isHidden = true
        button.tintColor = .systemGray4
        button.isUserInteractionEnabled = false
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "line.horizontal.3")
        return button
    }()
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        repo = nil
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(45)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(moveButton)
        moveButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }
    }
    
    func configure(with repo: MyRepo) {
        self.repo = repo
        nameLabel.text = repo.fullName
        moveButton.isHidden = !repo.isPublic
    }
    
    func getRepo() -> MyRepo? {
        return repo
    }
    
    func select() {
        moveButton.isHidden.toggle()
    }
    
}
