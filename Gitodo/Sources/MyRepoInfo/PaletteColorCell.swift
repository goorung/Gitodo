//
//  PaletteColorCell.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit

import SnapKit

final class PaletteColorCell: UICollectionViewCell, Reusable {
    
    // MARK: - UI Components
    
    private lazy var colorView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var highlightView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 동적으로 cornerRadius 설정
        colorView.layer.cornerRadius = colorView.bounds.width / 2
        highlightView.layer.cornerRadius = highlightView.bounds.width / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        unhighlightCell()
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        contentView.addSubview(colorView)
        colorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalToSuperview().multipliedBy(0.8)
        }
        
        contentView.addSubview(highlightView)
        highlightView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalToSuperview()
        }
    }
    
    func configure(with color: UIColor) {
        colorView.backgroundColor = color
        contentView.layoutIfNeeded()
    }
    
    func highlightCell() {
        highlightView.layer.borderWidth = 2.0
        highlightView.layer.borderColor = UIColor.systemGray3.cgColor
    }
    
    func unhighlightCell() {
        highlightView.layer.borderWidth = 0
        highlightView.layer.borderColor = nil
    }
    
}
