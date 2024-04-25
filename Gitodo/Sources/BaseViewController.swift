//
//  BaseViewController.swift
//  Gitodo
//
//  Created by 이지현 on 4/24/24.
//

import UIKit

import SnapKit

protocol BaseViewControllerProtocol {
    func setupNavigationBar()
}

class BaseViewController<View: UIView>: UIViewController, UIGestureRecognizerDelegate {
    
    enum TitlePosition {
        case left
        case center
    }

    private let topInsetView = UIView()

    private let navigationBarView = UIView()

    private lazy var leftButton = {
        let button = UIButton()
        button.tintColor = .label
        return button
    }()

    private lazy var titleLabel = {
        let label = UILabel()
        label.textColor = .label
        return label
    }()

    private lazy var rightButton = {
        let button = UIButton()
        button.tintColor = .label
        return button
    }()

    let contentView = View()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        view.backgroundColor = .systemBackground

        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(topInsetView)
        topInsetView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        view.addSubview(navigationBarView)
        navigationBarView.snp.makeConstraints { make in
            make.top.equalTo(topInsetView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }

        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(navigationBarView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

    }

    func setTitle(_ title: String, at position: TitlePosition = .center, font: UIFont = .systemFont(ofSize: 18, weight: .bold)) {
        titleLabel.text = title
        titleLabel.font = font
        
        setupTitleLayout(position)
    }
    
    private func setupTitleLayout(_ position: TitlePosition) {
        navigationBarView.addSubview(titleLabel)
        switch position {
        case .left:
            titleLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().inset(20)
                make.centerY.equalToSuperview()
            }
        case .center:
            titleLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
            }
        }
    }
    
    func setLeftButton(symbolName: String) {
        let configuration = UIImage.SymbolConfiguration(weight: .medium)
        leftButton.setImage(UIImage(systemName: symbolName, withConfiguration: configuration), for: .normal)
        
        setupLeftButtonLayout()
    }

    func setLeftButton(title: String) {
        leftButton.setTitle(title, for: .normal)
        leftButton.setTitleColor(.label, for: .normal)
        leftButton.titleLabel?.font = .systemFont(ofSize: 16.0, weight: .semibold)
        
        setupLeftButtonLayout()
    }
    
    private func setupLeftButtonLayout() {
        navigationBarView.addSubview(leftButton)
        leftButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }
    
    func setLeftButtonAction(_ action: Selector) {
        leftButton.addTarget(self, action: action, for: .touchUpInside)
    }

    func setRightButton(symbolName: String) {
        let configuration = UIImage.SymbolConfiguration(weight: .medium)
        rightButton.setImage(UIImage(systemName: symbolName, withConfiguration: configuration), for: .normal)
        
        setupRightButtonLayout()
    }
    
    func setRightButton(title: String?) {
        rightButton.setTitle(title, for: .normal)
        rightButton.setTitleColor(.label, for: .normal)
        rightButton.titleLabel?.font = .systemFont(ofSize: 16.0, weight: .semibold)
        
        setupRightButtonLayout()
    }
    
    private func setupRightButtonLayout() {
        navigationBarView.addSubview(rightButton)
        rightButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }

    func setRightButtonAction(_ action: Selector) {
        rightButton.addTarget(self, action: action, for: .touchUpInside)
    }

    func setLeftBackButton() {
        setLeftButton(symbolName: "chevron.backward")
        setLeftButtonAction(#selector(backButtonTapped))
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

}
