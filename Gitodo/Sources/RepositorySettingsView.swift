//
//  RepositorySettingsView.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit

import SnapKit

class RepositorySettingsView: UIView {
    
    private let insetFromSuperView: CGFloat = 20.0
    private let offsetFromOtherView: CGFloat = 25.0
    
    // MARK: - UI Components
    
    private lazy var previewView: UIView = {
        let view  = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var selectedRepositoryView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var repositoryListView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .secondarySystemBackground
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        addSubview(previewView)
        previewView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
        
        addSubview(selectedRepositoryView)
        selectedRepositoryView.snp.makeConstraints { make in
            make.top.equalTo(previewView.snp.bottom).offset(offsetFromOtherView)
            make.leading.trailing.equalToSuperview().inset(insetFromSuperView)
            make.height.equalTo(100)
        }
        addSubview(repositoryListView)
        repositoryListView.snp.makeConstraints { make in
            make.top.equalTo(selectedRepositoryView.snp.bottom).offset(offsetFromOtherView)
            make.leading.trailing.equalToSuperview().inset(insetFromSuperView)
            make.height.equalTo(100)
        }
    }
    
}
