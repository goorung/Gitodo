//
//  ToggleOptionView.swift
//  Gitodo
//
//  Created by 이지현 on 7/18/24.
//

import UIKit

import GitodoShared

import SnapKit

protocol ToggleOptionViewProtocol: AnyObject {
    func changeValue(_ value: Bool)
}

class ToggleOptionView: UIView {
    weak var delegate: ToggleOptionViewProtocol?
    
    private let title: String
    private var isSelected: Bool
    
    private lazy var titleLabel = {
        let label = UILabel()
        label.text = title
        label.textColor = .label
        label.font = .title4
        return label
    }()
    
    private lazy var toggleButton = {
        let button = UISwitch()
        button.isOn = isSelected
        button.onTintColor = UIColor(hex: PaletteColor.blue1.hex)
        button.addTarget(self, action: #selector(tappedToggleButton(sender:)), for: .valueChanged)
        return button
    }()

    init(title: String, isSelected: Bool) {
        self.title = title
        self.isSelected = isSelected
        super.init(frame: .zero)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
        }
        
        addSubview(toggleButton)
        toggleButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
    }
    
    func setButtonColor(_ hex: UInt) {
        toggleButton.onTintColor = UIColor(hex: hex)
    }
    
    func setStatus(_ isOn: Bool) {
        toggleButton.isOn = isOn
    }
    
    @objc func tappedToggleButton(sender: UISwitch) {
        delegate?.changeValue(sender.isOn)
    }
}
