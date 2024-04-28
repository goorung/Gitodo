//
//  TodoCell.swift
//  Gitodo
//
//  Created by 이지현 on 4/29/24.
//

import UIKit

import SnapKit

class TodoCell: UITableViewCell {
    static let reuseIdentifier = "TodoCell"
    var mainColor = UIColor.label
    var isComplete = false
    
    private lazy var checkbox = {
        let imageView = UIImageView(image: UIImage(systemName: "circle"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray4
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleCheckbox))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var todoTextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 15)
        textField.textColor = .label
        return textField
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        checkbox.image = UIImage(systemName: "circle")
        checkbox.tintColor = .systemGray4
        todoTextField.text = nil
        todoTextField.textColor = .label
    }
    
    private func setupLayout() {
        contentView.addSubview(checkbox)
        checkbox.snp.makeConstraints { make in
            make.height.width.equalTo(25)
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(todoTextField)
        todoTextField.snp.makeConstraints { make in
            make.leading.equalTo(checkbox.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(isComplete: Bool, todo: String?, color: UIColor) {
        mainColor = color
        todoTextField.text = todo
        self.isComplete = isComplete
        configureCheckbox(isComplete: isComplete)
    }
    
    @objc private func toggleCheckbox() {
        isComplete.toggle()
        configureCheckbox(isComplete: isComplete)
    }
    
    private func configureCheckbox(isComplete: Bool) {
        checkbox.image = UIImage(systemName: isComplete ? "checkmark.circle" : "circle")
        checkbox.tintColor = isComplete ? mainColor : .systemGray4
        todoTextField.textColor = isComplete ? .secondaryLabel : .label
    }
}
