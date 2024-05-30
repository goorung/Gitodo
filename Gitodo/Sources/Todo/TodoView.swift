//
//  TodoView.swift
//  Gitodo
//
//  Created by 이지현 on 5/17/24.
//

import UIKit

import GitodoShared

import RxCocoa
import RxSwift
import SnapKit

final class TodoView: UIView {
    
    private var viewModel: TodoViewModel?
    private var todoDataSource: UITableViewDiffableDataSource<TodoSection, TodoIdentifierItem>?
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private lazy var todoTableView = {
        let view = UITableView()
        view.backgroundColor = .background
        view.separatorStyle = .none
        view.rowHeight = UITableView.automaticDimension
        view.register(TodoCell.self, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        view.keyboardDismissMode = .interactive
        view.delegate = self
        return view
    }()
    
    private lazy var todoAddButton = {
        let button = UIButton()
        button.tintAdjustmentMode = .normal
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), for: .normal)
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), for: .highlighted)
        button.setTitle(" 할 일 추가", for: .normal)
        button.titleLabel?.font = .title3
        button.tintColor = .init(hex: PaletteColor.blue1.hex)
        button.setTitleColor(.init(hex: PaletteColor.blue1.hex), for: .normal)
        button.addTarget(self, action: #selector(todoAddButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var emptyLabel = {
        let label = UILabel()
        
        let text = """
        할 일이 비었어요.
        할 일을 추가해주세요! 😙
        """
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        label.attributedText = attributedString
        
        label.textAlignment = .center
        label.font = .bodySB
        label.textColor = .tertiaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .background
        setupLayout()
        configureDataSource()
        setupKeyboardObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        addSubview(todoTableView)
        todoTableView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        
        addSubview(todoAddButton)
        todoAddButton.snp.makeConstraints { make in
            make.top.equalTo(todoTableView.snp.bottom).offset(10)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(10)
        }
        
        addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-45)
        }
    }
    
    private func configureDataSource() {
        todoDataSource = UITableViewDiffableDataSource(tableView: todoTableView) { [weak self] tableView, indexPath, itemIdentifier in
            guard let self, let viewModel = self.viewModel else { fatalError() }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifier, for: indexPath) as? TodoCell else { fatalError() }
            cell.selectionStyle = .none
            cell.configure(with: viewModel.viewModel(at: indexPath))
            cell.checkbox.rx.tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [weak self] _ in
                    self?.generateHaptic()
                    viewModel.input.toggleTodo.onNext(itemIdentifier.id)
                })
                .disposed(by: cell.disposeBag)
            cell.delegate = self
            return cell
        }
    }
    
    private func setupKeyboardObservers() {
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
   }

   @objc private func keyboardWillShow(notification: Notification) {
       todoAddButton.isHidden = true
       todoAddButton.snp.remakeConstraints { make in
           make.top.equalTo(todoTableView.snp.bottom)
           make.height.equalTo(0)
           make.trailing.leading.bottom.equalToSuperview()
       }
       layoutIfNeeded()
       
       if let firstResponderIndexPath = viewModel?.firstResponderIndexPath {
           todoTableView.scrollToRow(at: firstResponderIndexPath, at: .none, animated: true)
           viewModel?.firstResponderIndexPath = nil
       }
   }

   @objc private func keyboardWillHide(notification: Notification) {
       todoAddButton.isHidden = false
       todoAddButton.snp.remakeConstraints { make in
           make.top.equalTo(todoTableView.snp.bottom).offset(10)
           make.trailing.equalToSuperview().inset(20)
           make.bottom.equalToSuperview().inset(10)
       }
       layoutIfNeeded()
   }
    
    @objc private func todoAddButtonTapped() {
        viewModel?.input.appendTodo.onNext(())
    }
    
    // MARK: - Bind
    
    func bind(with viewModel: TodoViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.todos
            .drive(onNext: { [weak self] viewModels in
                self?.emptyLabel.isHidden = !viewModels.isEmpty
                self?.applySnapshot(with: viewModels)
            }).disposed(by: disposeBag)
        
        viewModel.output.makeFirstResponder
            .drive(onNext: { [weak self] indexPath in
                guard let indexPath else { return }
                self?.todoTableView.scrollToRow(at: indexPath, at: .none, animated: true)
                guard let cell = self?.todoTableView.cellForRow(at: indexPath) as? TodoCell else {
                    self?.viewModel?.firstResponderIndexPath = indexPath
                    return
                }
                self?.generateHaptic()
                cell.todoBecomeFirstResponder()
            }).disposed(by: disposeBag)
        
        viewModel.output.resignFirstResponder
            .drive(onNext: { [weak self] indexPath in
                guard let indexPath else { return }
                guard let cell = self?.todoTableView.cellForRow(at: indexPath) as? TodoCell else { return }
                cell.todoResignFirstResponder()
            }).disposed(by: disposeBag)
    }
    
    private func applySnapshot(with viewModels: [TodoCellViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<TodoSection, TodoIdentifierItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModels.map{ $0.identifier })
        todoDataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func setAddButtonTintColor(_ color: UIColor) {
        todoAddButton.setTitleColor(color, for: .normal)
        todoAddButton.tintColor = color
    }
    
}

extension TodoView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { [weak self] action, view, completionHandler in
            guard let self = self,
                  let cell = tableView.cellForRow(at: indexPath) as? TodoCell,
                  let viewModel = cell.viewModel else { return }
            self.viewModel?.input.deleteTodo.onNext(viewModel.id)
            
            var snapshot = self.todoDataSource?.snapshot()
            snapshot?.deleteItems([viewModel.identifier])
            self.todoDataSource?.apply(snapshot!, animatingDifferences: true)
            
            completionHandler(true)
        }
        deleteAction.backgroundColor = .systemGray4
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return configuration
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let firstResponderIndexPath = viewModel?.firstResponderIndexPath, indexPath == firstResponderIndexPath else { return }
        guard let cell = cell as? TodoCell else { return }

        cell.todoBecomeFirstResponder()
    }
    
}

extension TodoView: TodoCellDelegate {
    
    func updateHeightOfRow(_ cell: TodoCell, _ textView: UITextView) {
        guard let viewModel = cell.viewModel,
            var snapshot = todoDataSource?.snapshot() else { return }
        
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        let newHeight = newSize.height
        
        if cell.previousHeight != newHeight {
            cell.previousHeight = newHeight
            snapshot.reconfigureItems([viewModel.identifier])
            todoDataSource?.apply(snapshot)
            if let indexPath = todoTableView.indexPath(for: cell) {
                todoTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
}
