//
//  RepositoryCell.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit

import GitodoShared

import SnapKit

final class RepositoryCell: UITableViewCell, Reusable {
    
    private var repo: MyRepo?
    
    // MARK: - UI Components
    
    private lazy var nameLabel = {
        let label = UILabel()
        label.font = .bodySB
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var moveImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "line.horizontal.3")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        contentView.addSubview(moveImageView)
        moveImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalTo(moveImageView.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(with repo: MyRepo) {
        self.repo = repo
        nameLabel.text = repo.fullName
    }
    
    func getRepo() -> MyRepo? {
        return repo
    }
    
}
