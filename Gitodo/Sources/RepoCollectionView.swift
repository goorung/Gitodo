//
//  RepoCollectionView.swift
//  Gitodo
//
//  Created by 이지현 on 4/29/24.
//

import UIKit

class RepoCollectionView: UICollectionView {
    
    var tempRepo = [
        (name: "algorithm", color: .systemMint, symbol: "☃️"),
        (name: "iOS", color: .systemBrown, symbol: "☁️"),
        (name: "Gitodo", color: .systemTeal, symbol: "🌝"),
        (name: "Inception", color: UIColor.systemGray, symbol: "💕"),
        (name: "algorithm", color: .systemMint, symbol: "☃️"),
        (name: "iOS", color: .systemGray, symbol: "☁️"),
        (name: "Gitodo", color: .systemTeal, symbol: "🌝"),
        (name: "Inception", color: UIColor.systemGray, symbol: "💕"),
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
        tempRepo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RepositoryInfoCell.reuseIdentifier, for: indexPath) as? RepositoryInfoCell else { return UICollectionViewCell() }
        let repo = tempRepo[indexPath.row]
        cell.configure(name: repo.name, color: repo.color, symbol: repo.symbol)
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
        let sourceItem = tempRepo[sourceIndexPath.item]
        
        DispatchQueue.main.async {
            self.tempRepo.remove(at: sourceIndexPath.item)
            self.tempRepo.insert(sourceItem, at: destinationIndexPath.item)
            let indexPaths = self.tempRepo
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
