//
//  TodoCell.swift
//  Gitodo
//
//  Created by 이지현 on 4/29/24.
//

import UIKit

import RxSwift
import SnapKit

protocol TodoCellDelegate: AnyObject {
    func updateHeightOfRow(_ cell: TodoCell, _ textView: UITextView)
}

class TodoCell: UITableViewCell {
    weak var delegate: TodoCellDelegate?
    static let reuseIdentifier = "TodoCell"
    var viewModel: TodoCellViewModel?
    var disposeBag = DisposeBag()
    
    lazy var checkbox = {
        let imageView = UIImageView(image: UIImage(systemName: "circle"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray4
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleCheckbox))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        imageView.tintAdjustmentMode = .normal
        return imageView
    }()
    
    private lazy var todoTextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 15)
        textView.textColor = .label
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.textContainer.maximumNumberOfLines = 0
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
        checkbox.image = UIImage(systemName: "circle")
        checkbox.tintColor = .systemGray4
        todoTextView.text = nil
        todoTextView.textColor = .label
    }
    
    private func setupLayout() {
        contentView.addSubview(checkbox)
        checkbox.snp.makeConstraints { make in
            make.height.width.equalTo(25)
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(todoTextView)
        todoTextView.snp.makeConstraints { make in
            make.leading.equalTo(checkbox.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.verticalEdges.equalToSuperview().inset(3)
        }
    }
    
    func configure(with viewModel: TodoCellViewModel) {
        self.viewModel = viewModel
        todoTextView.text = viewModel.todo
        configureCheckbox()
    }
    
    func todoBecomeFirstResponder() {
        todoTextView.becomeFirstResponder()
    }
    
    @objc private func toggleCheckbox() {
        viewModel?.isComplete.toggle()
    }
    
    private func configureCheckbox() {
        let isComplete = viewModel?.isComplete == true
        var tintColor = UIColor.label
        
        if let hex = viewModel?.tintColorHex {
            tintColor = UIColor(hex: hex)
        }
        
        checkbox.image = UIImage(systemName: isComplete ? "checkmark.circle" : "circle")
        checkbox.tintColor = isComplete ? tintColor : .systemGray4
        todoTextView.textColor = isComplete ? .secondaryLabel : .label
//        todoTextView.isUserInteractionEnabled = !isComplete
        todoTextView.isEditable = !isComplete
    }
}

extension TodoCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        viewModel?.beginEditing()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        viewModel?.todo = textView.text ?? ""
        delegate?.updateHeightOfRow(self, textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel?.endEditingTodo(with: textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView.text?.isEmpty == false {
                viewModel?.addNewTodoItem()
                return false
            } else {
                textView.resignFirstResponder()
                return false
            }
        }
        return true
    }
}
