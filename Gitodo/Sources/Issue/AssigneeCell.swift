//
//  AssigneeCell.swift
//  Gitodo
//
//  Created by jiyeon on 5/4/24.
//

import UIKit

import Kingfisher
import SnapKit

class AssigneeCell: UICollectionViewCell {
    
    static let reuseIdentifier = "AssigneeCell"
    
    // MARK: - UI Components
    
    private lazy var avataImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 동적으로 cornerRadius 설정
        avataImageView.layer.cornerRadius = frame.width / 2
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        addSubview(avataImageView)
        avataImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with avataUrl: String) {
        guard let url = URL(string: avataUrl) else { return }
        avataImageView.kf.setImage(with: url)
    }
    
}
