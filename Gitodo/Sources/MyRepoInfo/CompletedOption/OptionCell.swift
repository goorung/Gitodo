//
//  OptionCell.swift
//  GitodoShared
//
//  Created by 이지현 on 7/23/24.
//

import UIKit

import SnapKit

class OptionCell: UITableViewCell {
    
    static let reuseIdentifier = "OptionCell"
    
    // MARK: - UI Components
    
    private lazy var containerView = UIView()
    
    private lazy var labelStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 3
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var nameLabel = {
        let label = UILabel()
        label.font = .bodySB
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var selectedButton = {
        let button = UIButton()
        button.isHidden = true
        button.tintColor = .label
        button.isUserInteractionEnabled = false
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "checkmark")
        button.configuration?.preferredSymbolConfigurationForImage = .init(pointSize: 10.0, weight: .bold)
        return button
    }()
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(45)
            make.height.equalTo(50)
        }
        
        containerView.addSubview(labelStackView)
        labelStackView.snp.makeConstraints { make in
            make.horizontalEdges.centerY.equalToSuperview()
        }
        
        
        labelStackView.addArrangedSubview(nameLabel)
        
        contentView.addSubview(selectedButton)
        selectedButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(labelStackView)
            make.width.height.equalTo(15)
        }
    
    }
    
    func configure(title: String, isSelected: Bool) {
        nameLabel.text = title
        selectedButton.isHidden = !isSelected
    }
}
