//
//  SelectedOptionView.swift
//  Gitodo
//
//  Created by 이지현 on 7/18/24.
//

import UIKit

import SnapKit

class SelectedOptionView: UIView {
    
    private let title: String
    private var selectedOption: String
    
    private lazy var titleLabel = {
        let label = UILabel()
        label.text = title
        label.textColor = .label
        label.font = .title4
        return label
    }()
    
    private lazy var selectedOptionLabel = {
        let label = UILabel()
        label.text = selectedOption
        label.textColor = .label
        label.font = .title5
        return label
    }()
    
    private lazy var rightArrow = {
        let configuration = UIImage.SymbolConfiguration(weight: .medium)
        let view = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: configuration))
        view.tintColor = .label
        view.contentMode = .scaleAspectFit
        return view
    }()

    init(title: String, selectedOption: String) {
        self.title = title
        self.selectedOption = selectedOption
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
            make.leading.equalToSuperview().inset(8)
        }
        
        addSubview(rightArrow)
        rightArrow.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
            make.trailing.equalToSuperview().inset(8)
        }
        
        addSubview(selectedOptionLabel)
        selectedOptionLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(rightArrow.snp.leading).offset(-10)
        }
    }
    
    func setSelectedOption(_ selectedOption: String) {
        self.selectedOption = selectedOption
    }
    
    func setLabelText(_ text: String) {
        selectedOptionLabel.text = text
    }
}
