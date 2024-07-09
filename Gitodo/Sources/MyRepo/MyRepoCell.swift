//
//  MyRepoCell.swift
//  Gitodo
//
//  Created by 이지현 on 4/29/24.
//

import UIKit

import GitodoShared

import SnapKit

final class MyRepoCell: UICollectionViewCell, Reusable {
    
    private(set) var repository: MyRepo?
    
    // MARK: - UI Components
    
    private lazy var myRepoView = MyRepoView()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        myRepoView.reset()
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        contentView.addSubview(myRepoView)
        myRepoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(repository: MyRepo) {
        self.repository = repository
        myRepoView.setName(repository.nickname)
        myRepoView.setColor(UIColor(hex: repository.hexColor))
        myRepoView.setSymbol(repository.symbol)
    }
    
    func setEditMode() {
        myRepoView.setEditMode()
    }
    
}
