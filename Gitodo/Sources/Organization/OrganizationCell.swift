//
//  OrganizationCell.swift
//  Gitodo
//
//  Created by 지연 on 7/9/24.
//

import UIKit

import GitodoShared

import Kingfisher
import SnapKit

final class OrganizationCell: UITableViewCell, Reusable {
    
    private var organization: Organization?
    
    // MARK: - UI Component
    
    private lazy var profileImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    private lazy var nameLabel = {
        let label = UILabel()
        label.font = .bodySB
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var descriptionLabel = {
        let label = UILabel()
        label.font = .calloutSB
        label.textColor = .darkGray
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var chevronImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray3
        return imageView
    }()
    
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
        contentView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(chevronImageView)
        chevronImageView.snp.makeConstraints { make in
            make.width.height.equalTo(15)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalTo(profileImageView.snp.trailing).offset(15)
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-20)
            make.trailing.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.leading.equalTo(profileImageView.snp.trailing).offset(15)
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-20)
            make.bottom.equalToSuperview().inset(10)
        }
    }
    
    func configure(with organization: Organization) {
        self.organization = organization
        
        profileImageView.kf.setImage(with: URL(string: organization.avatarUrl))
        nameLabel.text = organization.login
        descriptionLabel.text = organization.description
    }
    
    func getOrganization() -> Organization? {
        return organization
    }
    
}
