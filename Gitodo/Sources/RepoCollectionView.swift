//
//  RepoCollectionView.swift
//  Gitodo
//
//  Created by 이지현 on 4/29/24.
//

import UIKit

class RepoCollectionView: UICollectionView {
    var repos: [MyRepo] = [] {
        didSet {
            reloadData()
        }
    }
    
    var selectedRepoId: Int? {
        didSet {
            reloadData()
        }
    }
    
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
        delegate = self
        dragDelegate = self
        dropDelegate = self
        dragInteractionEnabled = true
        register(RepositoryInfoCell.self, forCellWithReuseIdentifier: RepositoryInfoCell.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension RepoCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        repos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RepositoryInfoCell.reuseIdentifier, for: indexPath) as? RepositoryInfoCell else { return UICollectionViewCell() }
        let repo = repos[indexPath.row]
        cell.configure(name: repo.nickname, color: UIColor(hex: repo.hexColor), symbol: repo.symbol)
        if let selectedRepoId,
           selectedRepoId != repo.id {
            cell.contentView.alpha = 0.5
        } else {
            cell.contentView.alpha = 1
        }
        return cell
    }
    
}

extension RepoCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        true
    }
}

extension RepoCollectionView: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        [UIDragItem(itemProvider: NSItemProvider())]
    }
}

extension RepoCollectionView: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let row = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(item: row - 1, section: 0)
        }
        
        guard coordinator.proposal.operation == .move else { return }
        move(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
    }
    
    private func move(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        guard let sourceItem = coordinator.items.first,
              let sourceIndexPath = sourceItem.sourceIndexPath
        else { return }
        
        performBatchUpdates { [weak self] in
            self?.move(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
        } completion: { finish in
            coordinator.drop(sourceItem.dragItem, toItemAt: destinationIndexPath)
        }
        
    }
    
    private func move(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        let sourceItem = repos[sourceIndexPath.item]
        
        DispatchQueue.main.async {
            self.repos.remove(at: sourceIndexPath.item)
            self.repos.insert(sourceItem, at: destinationIndexPath.item)
            TempRepository.updateRepoOrder(self.repos.map{ $0.id })
            NotificationCenter.default.post(name: .RepositoryOrderDidUpdate, object: self)
            let indexPaths = self.repos
                .enumerated()
                .map(\.offset)
                .map{ IndexPath(row: $0, section: 0) }
            UIView.performWithoutAnimation {
                self.reloadItems(at: indexPaths)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard hasActiveDrag else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
}
