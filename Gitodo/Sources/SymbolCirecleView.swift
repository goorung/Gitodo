//
//  SymbolCirecleView.swift
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        makeCircle()
        setupLayout()
    }
    
    private func makeCircle() {
        layer.cornerRadius = frame.width / 2
        clipsToBounds = true
    }
    
    private func setupLayout() {
        addSubview(symbolLabel)
        symbolLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(frame.width / 5.5)
        }
    }
    
    func setBackgroundColor(_ color: UIColor) {
        backgroundColor = color
    }
    
    func setSymbol(_ symbol: String) {
        symbolLabel.text = symbol
    }
    
    func setImage(_ image: UIImage?) {
        self.image = image
    }
    
}
