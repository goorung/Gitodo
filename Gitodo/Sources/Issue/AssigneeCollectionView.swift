//
//  AssigneeCollectionView.swift
//  Gitodo
//
//  Created by jiyeon on 5/3/24.
//

import UIKit

import GitodoShared

import SnapKit

final class AssigneeCollectionView: UICollectionView {
    
    private var assignees: [User]? {
        didSet {
            reloadData()
        }
    }
    
    private let itemsPerRow: CGFloat = 10.0
    private let spacing: CGFloat = 5.0
    
    // MARK: - Reload Data
    
    override func reloadData() {
        super.reloadData()
        DispatchQueue.main.async { [weak self] in
            self?.updateHeightConstraint()
        }
    }
    
    private func updateHeightConstraint() {
        let height = self.collectionViewLayout.collectionViewContentSize.height
        self.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.isActive = false
                self.removeConstraint(constraint)
            }
        }
        let heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height)
        heightConstraint.priority = UILayoutPriority(999)
        self.addConstraint(heightConstraint)
        
        NotificationCenter.default.post(name: .AssigneeCollectionViewHeightDidUpdate, object: self)
    }
    
    // MARK: - Initializer
    
    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        setupProperty()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupProperty() {
        delegate = self
        dataSource = self
        register(cellType: AssigneeCell.self)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    func configure(with assignees: [User]?) {
        guard let assignees = assignees else { return }
        self.assignees = assignees
    }
    
}

extension AssigneeCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = spacing * itemsPerRow * 2
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
}

extension AssigneeCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assignees?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let assignees = assignees else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: AssigneeCell.self)
        cell.configure(with: assignees[indexPath.row].avatarUrl)
        return cell
    }
    
}
