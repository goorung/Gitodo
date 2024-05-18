//
//  RepositoryCell.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit

import SnapKit

class RepositoryCell: UITableViewCell {
    
    static let reuseIdentifier = "RepositoryCell"
    private var repo: MyRepo?
    private let insetFromSuperView: CGFloat = 20.0
    
    // MARK: - UI Components
    
    private lazy var nameLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15.0, weight: .medium)
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
        
        selectionStyle = .none
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        repo = nil
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(insetFromSuperView)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(selectedButton)
        selectedButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(insetFromSuperView)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }
    }
    
    func configure(with repo: MyRepo) {
        self.repo = repo
        nameLabel.text = repo.fullName
        selectedButton.isHidden = !repo.isPublic
    }
    
    func selectCell() -> MyRepo? {
        selectedButton.isHidden.toggle()
        return repo
    }
    
}
