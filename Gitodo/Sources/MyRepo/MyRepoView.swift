//
//  MyRepoView.swift
//  Gitodo
//
//  Created by 이지현 on 4/25/24.
//

import UIKit

import SnapKit

final class MyRepoView: UIView {
    
    // MARK - UI Components
    
    private lazy var circleView = SymbolCircleView()
    
    private lazy var editLabel = {
        let label = UILabel()
        label.text = "편집"
        label.textColor = .label
        label.textAlignment = .center
        label.font = .caption
        label.isHidden = true
        return label
    }()
    
    private lazy var nameLabel = {
        let label = UILabel()
        label.font = .footnote
        label.textAlignment = .center
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupLayout()
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        addSubview(circleView)
        circleView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.width.height.equalTo(frame.width)
        }
        
        addSubview(editLabel)
        editLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(circleView.snp.centerY)
        }
        
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(circleView.snp.bottom).offset(5)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func setName(_ name: String?) {
        nameLabel.text = name
    }
    
    func setColor(_ color: UIColor) {
        circleView.setBackgroundColor(color)
    }
    
    func setSymbol(_ symbol: String?) {
        circleView.setSymbol(symbol)
    }
    
    func reset() {
        nameLabel.text = nil
        editLabel.isHidden = true
        circleView.reset()
    }
    
    func setEditMode() {
        circleView.alpha = 0.5
        editLabel.isHidden = false
    }
    
}
