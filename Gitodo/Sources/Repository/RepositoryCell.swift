//
//  RepositoryCell.swift
//  Gitodo
//
//  Created by 지연 on 7/10/24.
//

import UIKit

final class RepositoryCell: UITableViewCell, Reusable {
 
    // MARK: - UI Components
    
    private lazy var nameLabel = {
        let label = UILabel()
        label.font = .bodySB
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var selectButton = {
        let button = UIButton()
        return button
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
        contentView.addSubview(selectButton)
        selectButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalTo(selectButton.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(with viewModel: RepositoryCellViewModel) {
        nameLabel.text = viewModel.repository.name
        setPublic(viewModel.isPublic)
    }
    
    func setPublic(_ isPublic: Bool) {
        let image = isPublic ?
        UIImage(systemName: "circle.inset.filled") :
        UIImage(systemName: "circle")
        selectButton.setImage(image, for: .normal)
        selectButton.tintColor = isPublic ? .black : .systemGray
    }
    
}
