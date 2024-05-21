//
//  SymbolCircleView.swift
//  Gitodo
//
//  Created by 이지현 on 4/25/24.
//

import UIKit

import SnapKit

class SymbolCircleView: UIImageView {
    
    private lazy var symbolLabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 100)
        label.minimumScaleFactor = 0.01
        return label
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .systemGray4
        contentMode = .scaleAspectFill
        clipsToBounds = true
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        makeCircle()
    }
    
    func makeCircle() {
        layer.cornerRadius = frame.width / 2
    }
    
    private func setupLayout() {
        addSubview(symbolLabel)
        symbolLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalToSuperview().multipliedBy(0.64)
        }
    }
    
    func setBackgroundColor(_ color: UIColor) {
        backgroundColor = color
    }
    
    func setSymbol(_ symbol: String?) {
        symbolLabel.text = symbol
    }
    
    func setImage(_ image: UIImage?) {
        self.image = image
    }
    
    func reset() {
        alpha = 1
        backgroundColor = .systemGray4
        symbolLabel.text = nil
        image = nil
    }
    
}
