//
//  RepoCollectionView.swift
//  Gitodo
//
//  Created by 이지현 on 4/29/24.
//

import UIKit

class RepoCollectionView: UICollectionView {
    
    let tempRepo = [
        (name: "algorithm", color: UIColor.systemMint, symbol: "☃️"),
        (name: "iOS", color: UIColor.systemGray, symbol: "☁️"),
    ]
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 80)
        layout.minimumLineSpacing = 13
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        isScrollEnabled = true
        showsHorizontalScrollIndicator = false
        contentInset = .zero
        backgroundColor = .clear
        clipsToBounds = true
        dataSource = self
        register(RepositoryInfoCell.self, forCellWithReuseIdentifier: RepositoryInfoCell.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension RepoCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tempRepo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RepositoryInfoCell.reuseIdentifier, for: indexPath) as? RepositoryInfoCell else { return UICollectionViewCell() }
        let repo = tempRepo[indexPath.row]
        cell.configure(name: repo.name, color: repo.color, symbol: repo.symbol)
        return cell
    }
    
}
