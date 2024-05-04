//
//  MenuCell.swift
//  Gitodo
//
//  Created by jiyeon on 5/4/24.
//

import UIKit

import SnapKit

class MenuCell: UITableViewCell {
    
    static let reuseIdentifier = "MenuCell"
    
    // MARK: - UI Components
    
    private lazy var titleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13.0)
        return label
    }()
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(with menu: MenuType) {
        titleLabel.text = menu.title
    }
    
}
