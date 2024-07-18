//
//  MyRepoInfoView.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit

import GitodoShared

import SnapKit
import RxCocoa
import RxSwift

final class MyRepoInfoView: UIView {
    
    private var viewModel: MyRepoInfoViewModel?
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private lazy var containerView: UIScrollView = {
        let view = UIScrollView()
        view.isScrollEnabled = true
        return view
    }()
    
    private lazy var previewLabel: UILabel = {
        let label = createLabel(withText: "미리보기")
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var previewView: MyRepoView = {
        let view = MyRepoView()
        return view
    }()
    
    private lazy var nicknamelabel: UILabel = {
        let label = createLabel(withText: "레포지토리 별명")
        return label
    }()
    
    private lazy var topSeparator: UIView = createSeparator()
    
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
    
    private lazy var optionTopSeparator: UIView = createSeparator()
    
    private lazy var settingLabel: UILabel = {
        let label = createLabel(withText: "레포지토리 설정")
        return label
    }()
    
    private lazy var deleteOptionView = SelectedOptionView(title: "완료된 할 일 자동 삭제", selectedOption: "3시간 후")
    
    private lazy var hideOptionView = {
        let view = ToggleOptionView(title: "완료된 할 일 숨기기", isSelected: false)
        view.delegate = self
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
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.addSubview(previewLabel)
        previewLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
            make.width.greaterThanOrEqualTo(300)
        }
        
        containerView.addSubview(previewView)
        previewView.snp.makeConstraints { make in
            make.top.equalTo(previewLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(80)
        }
        
        containerView.addSubview(topSeparator)
        topSeparator.snp.makeConstraints { make in
            make.top.equalTo(previewView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        
        containerView.addSubview(nicknamelabel)
        nicknamelabel.snp.makeConstraints { make in
            make.top.equalTo(topSeparator.snp.bottom).offset(15)
            make.leading.equalToSuperview().inset(20)
        }
        
        containerView.addSubview(nicknameTextField)
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(nicknamelabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        containerView.addSubview(symbolLabel)
        symbolLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(15)
            make.leading.equalToSuperview().inset(20)
        }
        
        containerView.addSubview(symbolTextField)
        symbolTextField.snp.makeConstraints { make in
            make.top.equalTo(symbolLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        containerView.addSubview(colorLabel)
        colorLabel.snp.makeConstraints { make in
            make.top.equalTo(symbolTextField.snp.bottom).offset(15)
            make.leading.equalToSuperview().inset(20)
        }
        
        containerView.addSubview(colorView)
        colorView.snp.makeConstraints { make in
            make.top.equalTo(colorLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        containerView.addSubview(optionTopSeparator)
        optionTopSeparator.snp.makeConstraints { make in
            make.top.equalTo(colorView.snp.bottom).offset(25)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        
        containerView.addSubview(settingLabel)
        settingLabel.snp.makeConstraints { make in
            make.top.equalTo(optionTopSeparator.snp.bottom).offset(15)
            make.leading.equalToSuperview().inset(20)
        }
        
        containerView.addSubview(deleteOptionView)
        deleteOptionView.snp.makeConstraints { make in
            make.top.equalTo(settingLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(42)
        }
        
        containerView.addSubview(hideOptionView)
        hideOptionView.snp.makeConstraints { make in
            make.top.equalTo(deleteOptionView.snp.bottom)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(42)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    // MARK: - Bind
    
    private func bind() {
        nicknameTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                guard let self = self, let viewModel = self.viewModel else { return }
                let nameToSet = text.isEmpty ? viewModel.name : text
                self.previewView.setName(nameToSet)
                viewModel.nickname = nameToSet
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
                    self.viewModel?.symbol = symbolToSet
                } else {
                    self.previewView.setSymbol(nil)
                    self.viewModel?.symbol = nil
                }
            }).disposed(by: disposeBag)
    }
    
    func bind(with viewModel: MyRepoInfoViewModel) {
        self.viewModel = viewModel
        
        previewLabel.text = "\(viewModel.fullName) 미리보기"
        previewView.setName(viewModel.nickname)
        previewView.setSymbol(viewModel.symbol)
        previewView.setColor(UIColor(hex: viewModel.hexColor))
        
        nicknameTextField.text = viewModel.nickname
        symbolTextField.text = viewModel.symbol
        colorView.setInitialColor(viewModel.hexColor)
        hideOptionView.setButtonColor(viewModel.hexColor)
        hideOptionView.setStatus(viewModel.hideCompletedTasks)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
    
}

extension MyRepoInfoView {
    
    private func createSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }
    
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .label
        label.font = .bodyB
        return label
    }
    
    private func createTextField() -> UITextField {
        let textField = UITextField()
        textField.backgroundColor = .background
        textField.borderStyle = .roundedRect
        textField.font = .callout
        return textField
    }
    
}

extension MyRepoInfoView: PaletteColorDelegate {
    
    func selectColor(_ color: PaletteColor) {
        previewView.setColor(UIColor(hex: color.hex))
        hideOptionView.setButtonColor(color.hex)
        viewModel?.hexColor = color.hex
    }
    
}

extension MyRepoInfoView: ToggleOptionViewProtocol {
    func changeValue(_ value: Bool) {
        viewModel?.hideCompletedTasks = value
    }
    
}
