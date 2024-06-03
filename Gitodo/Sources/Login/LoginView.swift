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

final class LoginView: UIView {
    
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
            attributes: .init([
                .font: UIFont.body,
                .foregroundColor: UIColor.background
            ])
        )
        button.clipsToBounds = true
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(handleLoginButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var loadingImages: [UIImage] = {
        return [
            UIImage(named: "loading_1.png"),
            UIImage(named: "loading_2.png"),
            UIImage(named: "loading_3.png"),
            UIImage(named: "loading_4.png")
        ].compactMap { $0 }
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
        addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.width.height.equalTo(150)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.snp.centerY).offset(-40)
        }
        
        addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(80)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(60)
        }
    }
    
    @objc private func handleLoginButtonTap() {
        delegate?.loginWithGithub()
    }
    
    func startLoading() {
        logoImageView.animationImages = loadingImages
        logoImageView.animationDuration = 1.5
        logoImageView.startAnimating()
    }
    
    func endLoading() {
        logoImageView.stopAnimating()
        logoImageView.image = UIImage(named: "logo.png")
    }
    
}
