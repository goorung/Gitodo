//
//  SelectedRepositoryCell.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit

import SnapKit

class SelectedRepositoryCell: UITableViewCell {
    
    static let reuseIdentifier = "SelectedRepositoryCell"
    private let insetFromSuperView: CGFloat = 20.0
    
    // MARK: - UI Components
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15.0, weight: .medium)
        return label
    }()
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(insetFromSuperView)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(withName name: String) {
        nameLabel.text = name
    }
    
}