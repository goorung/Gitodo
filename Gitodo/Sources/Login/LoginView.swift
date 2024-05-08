//
//  LoginView.swift
//  Gitodo
//
//  Created by jiyeon on 5/6/24.
//

import UIKit

import SnapKit

protocol LoginDelegate: AnyObject {
    func loginWithGithub()
}

class LoginView: UIView {
    
    weak var delegate: LoginDelegate?
    
    // MARK: - UI Components
    
    private lazy var loginButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.tintColor = .label
        button.configuration?.attributedTitle = .init(
            "Login with Github",
            attributes: .init([.font: UIFont.boldSystemFont(ofSize: 15.0)])
        )
        button.addTarget(self, action: #selector(handleLoginButtonTap), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(180)
            make.height.equalTo(50)
        }
    }
    
    @objc private func handleLoginButtonTap() {
        delegate?.loginWithGithub()
    }
    
}
