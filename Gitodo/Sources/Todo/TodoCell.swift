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

final class TodoCell: UITableViewCell, Reusable {
    
    weak var delegate: TodoCellDelegate?
    var viewModel: TodoCellViewModel?
    var disposeBag = DisposeBag()
    
    var previousHeight: CGFloat = 0
    
    // MARK: - UI Components
    
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
        textView.backgroundColor = .clear
        textView.font = .body
        textView.textColor = .label
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.textContainer.maximumNumberOfLines = 0
        return textView
    }()
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
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
    
    // MARK: - Setup Methods
    
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
            make.verticalEdges.equalToSuperview().inset(7)
        }
    }
    
    func configure(with viewModel: TodoCellViewModel) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        todoTextView.text = viewModel.todo
        configureCheckbox()
    }
    
    func todoBecomeFirstResponder() {
        todoTextView.becomeFirstResponder()
    }
    
    func todoResignFirstResponder() {
        todoTextView.resignFirstResponder()
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
