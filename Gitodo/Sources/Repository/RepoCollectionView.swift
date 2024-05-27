//
//  RepoCollectionView.swift
//  Gitodo
//
//  Created by 이지현 on 4/29/24.
//

import UIKit

import GitodoShared

final class RepoCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    
    let localRepositoryService = LocalRepositoryService()
    let isEditMode: Bool
    
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
    
    // MARK: - Initializer
    
    init(isEditMode: Bool) {
        self.isEditMode = isEditMode
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 80)
        layout.minimumLineSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
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
        cell.configure(repository: repo)
        
        if isEditMode {
            cell.setEditMode()
            return cell
        }
        
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
        return isEditMode
    }
    
}

extension RepoCollectionView: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard isEditMode else { return [] }
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
    
}

extension RepoCollectionView: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard isEditMode else { return }
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
            do {
                self.repos.remove(at: sourceIndexPath.item)
                self.repos.insert(sourceItem, at: destinationIndexPath.item)
                try self.localRepositoryService.updateOrder(of: self.repos)
                NotificationCenter.default.post(name: .RepositoryOrderDidUpdate, object: self)
                let indexPaths = self.repos
                    .enumerated()
                    .map(\.offset)
                    .map{ IndexPath(row: $0, section: 0) }
                UIView.performWithoutAnimation {
                    self.reloadItems(at: indexPaths)
                }
            } catch {
                print("[RepoCollectionView] move failed : \(error.localizedDescription)")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard isEditMode, hasActiveDrag else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
}
