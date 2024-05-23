//
//  LabelCollectionView.swift
//  Gitodo
//
//  Created by jiyeon on 5/4/24.
//

import UIKit

import GitodoShared

class LabelCollectionView: UICollectionView {
    
    private var labels: [Label]? {
        didSet {
            reloadData()
        }
    }
    
    private var heightConstraint: NSLayoutConstraint?
    
    // MARK: - Initializer
    
    init() {
        super.init(frame: .zero, collectionViewLayout: LeftAlignedCollectionViewFlowLayout())
        
        setupProperty()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        NotificationCenter.default.post(name: .LabelCollectionViewHeightDidUpdate, object: self)
    }
    
    // MARK: - Setup Methods
    
    private func setupProperty() {
        delegate = self
        dataSource = self
        register(LabelCell.self, forCellWithReuseIdentifier: LabelCell.reuseIdentifier)
        isUserInteractionEnabled = false
    }
    
    func configure(with labels: [Label]?) {
        self.labels = labels
    }
    
}

extension LabelCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let labels = labels else { return .zero }
        
        let label = UILabel()
        label.font = .caption
        label.text = labels[indexPath.row].name
        label.sizeToFit()
        let size = label.frame.size
        
        return CGSize(width: size.width + 20, height: size.height + 8)
    }
    
}

extension LabelCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return labels?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let labels = labels else { return UICollectionViewCell() }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LabelCell.reuseIdentifier, for: indexPath) as? LabelCell else {
            fatalError("Unable to dequeue IssueCell")
        }
        cell.configure(with: labels[indexPath.row])
        return cell
    }
    
}

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        
        return attributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: indexPath)
        
        if let attributes = attributes {
            var leftMargin = sectionInset.left
            let maxY: CGFloat = -1.0
            
            if attributes.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            
            attributes.frame.origin.x = leftMargin
        }
        
        return attributes
    }
    
}
