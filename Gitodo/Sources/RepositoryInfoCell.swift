//
//  RepositoryInfoCell.swift
//  Gitodo
//
//  Created by 이지현 on 4/29/24.
//

import UIKit

import GitodoShared

import SnapKit

class RepositoryInfoCell: UICollectionViewCell {
    static let reuseIdentifier = "RepositoryInfoCell"
    private(set) var repository: MyRepo?
    
    private lazy var repositoryView = RepositoryView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        repositoryView.reset()
    }
    
    private func setupLayout() {
        contentView.addSubview(repositoryView)
        repositoryView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(repository: MyRepo) {
        self.repository = repository
        repositoryView.setName(repository.nickname)
        repositoryView.setColor(UIColor(hex: repository.hexColor))
        repositoryView.setSymbol(repository.symbol)
    }
    
    func setEditMode() {
        repositoryView.setEditMode()
    }
}
