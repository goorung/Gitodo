//
//  RepositoryInfoView.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift

class RepositoryInfoView: UIView {
    
    // temp !
    private let repoName = "Gitodo"
    
    private let disposeBag = DisposeBag()
    
    private let insetFromSuperView: CGFloat = 20.0
    private let offsetFromOtherView: CGFloat = 15.0
    private let offsetFromFriendView: CGFloat = 10.0
    
    // MARK: - UI Components
    
    private lazy var previewLabel: UILabel = {
        let label = createLabel(withText: "\(repoName) 미리보기")
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var previewView: RepositoryView = {
        let view = RepositoryView()
        view.setName(repoName)
        return view
    }()
    
    private lazy var nicknamelabel: UILabel = {
        let label = createLabel(withText: "레포지토리 별명")
        return label
    }()
    
    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()
    
    private lazy var nicknameTextField: UITextField = {
        let textField = createTextField()
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private lazy var symbolLabel: UILabel = {
        let label = createLabel(withText: "레포지토리 심볼")
        return label
    }()
    
    private lazy var symbolTextField: UITextField = {
        let textField = createTextField()
        return textField
    }()
    
    private lazy var colorLabel: UILabel = {
        let label = createLabel(withText: "레포지토리 색상")
        return label
    }()
    
    private lazy var colorView: PaletteColorView = {
        let view = PaletteColorView()
        view.colorDelegate = self
        return view
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        addSubview(previewLabel)
        previewLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(insetFromSuperView)
        }
        
        addSubview(previewView)
        previewView.snp.makeConstraints { make in
            make.top.equalTo(previewLabel.snp.bottom).offset(offsetFromFriendView)
            make.centerX.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(80)
        }
        
        addSubview(separator)
        separator.snp.makeConstraints { make in
            make.top.equalTo(previewView.snp.bottom).offset(offsetFromOtherView)
            make.leading.trailing.equalToSuperview().inset(insetFromSuperView)
            make.height.equalTo(1)
        }
        
        addSubview(nicknamelabel)
        nicknamelabel.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom).offset(offsetFromOtherView)
            make.leading.equalToSuperview().inset(insetFromSuperView)
        }
        
        addSubview(nicknameTextField)
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(nicknamelabel.snp.bottom).offset(offsetFromFriendView)
            make.leading.trailing.equalToSuperview().inset(insetFromSuperView)
        }
        
        addSubview(symbolLabel)
        symbolLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(offsetFromOtherView)
            make.leading.equalToSuperview().inset(insetFromSuperView)
        }
        
        addSubview(symbolTextField)
        symbolTextField.snp.makeConstraints { make in
            make.top.equalTo(symbolLabel.snp.bottom).offset(offsetFromFriendView)
            make.leading.trailing.equalToSuperview().inset(insetFromSuperView)
        }
        
        addSubview(colorLabel)
        colorLabel.snp.makeConstraints { make in
            make.top.equalTo(symbolTextField.snp.bottom).offset(offsetFromOtherView)
            make.leading.equalToSuperview().inset(insetFromSuperView)
        }
        
        addSubview(colorView)
        colorView.snp.makeConstraints { make in
            make.top.equalTo(colorLabel.snp.bottom).offset(offsetFromFriendView)
            make.leading.trailing.equalToSuperview().inset(insetFromSuperView)
            make.bottom.equalToSuperview().inset(insetFromSuperView)
        }
    }
    
    // MARK: - Bind
    
    private func bind() {
        nicknameTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                let nameToSet = text.isEmpty ? repoName : text
                self.previewView.setName(nameToSet)
            }).disposed(by: disposeBag)
        
        symbolTextField.rx.text
            .distinctUntilChanged()
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                if let lastChar = text.last {
                    let symbolToSet = String(lastChar)
                    self.symbolTextField.text = symbolToSet
                    self.previewView.setSymbol(symbolToSet)
                } else {
                    self.previewView.setSymbol(nil)
                }
            }).disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
    
}

extension RepositoryInfoView {
    
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .label
        label.font = .boldSystemFont(ofSize: 15)
        return label
    }
    
    private func createTextField() -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 13)
        return textField
    }
    
}

extension RepositoryInfoView: PaletteColorDelegate {
    
    func selectColor(_ color: PaletteColor) {
        previewView.setColor(UIColor(hex: color.hex))
    }
    
}
