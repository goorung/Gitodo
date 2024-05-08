//
//  AssigneeCollectionView.swift
//  Gitodo
//
//  Created by jiyeon on 5/3/24.
//

import UIKit

import SnapKit

class AssigneeCollectionView: UICollectionView {
    
    private var assignees: [User]? {
        didSet {
            reloadData()
        }
    }
    
    private let itemsPerRow: CGFloat = 10.0
    private let spacing: CGFloat = 5.0
    
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
        self.delegate = self
        self.dataSource = self
        self.register(AssigneeCell.self, forCellWithReuseIdentifier: AssigneeCell.reuseIdentifier)
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssigneeCell.reuseIdentifier, for: indexPath) as? AssigneeCell else {
            fatalError("Unable to dequeue AssigneeCell")
        }
//        cell.configure(with: assignees[indexPath.row].avataUrl)
        cell.configure(with: "https://avatars.githubusercontent.com/u/116897060")
        return cell
    }
    
}
