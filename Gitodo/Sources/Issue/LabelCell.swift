//
//  LabelCell.swift
//  Gitodo
//
//  Created by jiyeon on 5/4/24.
//

import UIKit

import GitodoShared

import SnapKit

final class LabelCell: UICollectionViewCell, Reusable {
    
    // MARK: - UI Components
    
    private lazy var nameLabel = {
        let label = UILabel()
        label.font = .caption
        label.textColor = .black
        return label
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.height / 2
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func configure(with label: Label?) {
        guard let label = label else { return }
        nameLabel.text = label.name
        if let color = UInt(label.color, radix: 16) {
            backgroundColor = UIColor(hex: color)
        }
    }
    
}
