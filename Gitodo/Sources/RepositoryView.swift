//
//  RepositoryView.swift
//  Gitodo
//
//  Created by 이지현 on 4/25/24.
//

import UIKit

import SnapKit

class RepositoryView: UIView {
    
    private lazy var circleView = SymbolCircleView()
    
    private lazy var nameLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupLayout()
    }
    
    private func setupLayout() {
        addSubview(circleView)
        circleView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.width.height.equalTo(frame.width)
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
        circleView.reset()
    }
    
}
