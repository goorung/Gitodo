//
//  LoginView.swift
//  Gitodo
//
//  Created by jiyeon on 5/6/24.
//

import UIKit

import SnapKit
import SwiftyToaster

protocol LoginDelegate: AnyObject {
    func loginWithGithub()
}

class LoginView: UIView {
    
    weak var delegate: LoginDelegate?
    
    // MARK: - UI Components
    
    private lazy var logoImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo.png")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var loginButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.tintColor = .label
        button.configuration?.attributedTitle = .init(
            "Github 계정으로 로그인",
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
            make.leading.trailing.equalToSuperview().inset(30)
            make.centerY.equalTo(self.snp.centerY).offset(30)
            make.height.equalTo(55)
        }
        
        addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.width.height.equalTo(120)
            make.bottom.equalTo(loginButton.snp.top).offset(-60)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc private func handleLoginButtonTap() {
        Toaster.shared.makeToast("test")
//        delegate?.loginWithGithub()
    }
    
}
