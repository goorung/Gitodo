//
//  EmptyView.swift
//  Gitodo
//
//  Created by 지연 on 7/11/24.
//

import UIKit

import SnapKit

final class EmptyView: UIView {
    
    // MARK: - UI Components
    
    private lazy var emptyLabel = {
        let label = UILabel()
        label.font = .bodySB
        label.textColor = .tertiaryLabel
        return label
    }()
    
    // MARK: - Initializer
    
    init(message: String) {
        super.init(frame: .zero)
        
        emptyLabel.setTextWithLineHeight(message)
        emptyLabel.textAlignment = .center
        setupProperty()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Layout
    
    private func setupProperty() {
        backgroundColor = .background
        clipsToBounds = true
        layer.cornerRadius = 10
    }
    
    private func setupLayout() {
        addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
}
