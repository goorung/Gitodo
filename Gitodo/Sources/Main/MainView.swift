//
//  MainView.swift
//  Gitodo
//
//  Created by 이지현 on 4/25/24.
//

import UIKit

import RxCocoa
import RxSwift
import RxGesture
import SnapKit

class MainView: UIView {
    
    private var viewModel: MainViewModel?
    private let issueViewModel = IssueViewModel()
    private let disposeBag = DisposeBag()
    
    private lazy var repoCollectionView = {
        let collectionView = RepoCollectionView()
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var separator = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private lazy var segmentedControl = {
        let control = UISegmentedControl(items: ["할 일", "이슈"])
        control.selectedSegmentIndex = 0
        
        let normalAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.systemGray,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .semibold)
        ]
        let selectedAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(hex: PaletteColor.blue2.hex),
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .semibold)
        ]
        
        control.setTitleTextAttributes(normalAttributes, for: .normal)
        control.setTitleTextAttributes(selectedAttributes, for: .selected)
        
        control.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        
        return control
    }()
    
    private lazy var todoView = UIView()
    
    private lazy var todoTableView = {
        let view = UITableView()
        view.separatorStyle = .none
        view.rowHeight = 46
        view.register(TodoCell.self, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        view.keyboardDismissMode = .interactive
        return view
    }()
    
    private lazy var todoAddButton = {
        let button = UIButton()
        button.tintAdjustmentMode = .normal
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), for: .normal)
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), for: .highlighted)
        button.setTitle(" 할 일 추가", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.tintColor = .init(hex: PaletteColor.blue2.hex)
        button.setTitleColor(.init(hex: PaletteColor.blue2.hex), for: .normal)
        button.addTarget(self, action: #selector(todoAddButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var issueView = {
        let view = IssueTableView()
        view.bind(with: issueViewModel)
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(repoCollectionView)
        repoCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(80)
        }
        
        addSubview(separator)
        separator.snp.makeConstraints { make in
            make.top.equalTo(repoCollectionView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(2)
        }
        
        addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(separator).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
        }
        
        addSubview(todoView)
        todoView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(keyboardLayoutGuide.snp.top)
        }
        
        todoView.addSubview(todoTableView)
        todoTableView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        
        todoView.addSubview(todoAddButton)
        todoAddButton.snp.makeConstraints { make in
            make.top.equalTo(todoTableView.snp.bottom).offset(10)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(10)
        }
        
        addSubview(issueView)
        issueView.snp.makeConstraints { make in
            make.edges.equalTo(todoView)
        }
    }
    
    @objc private func segmentedControlChanged(_ segment: UISegmentedControl) {
        todoView.isHidden = segment.selectedSegmentIndex != 0
        issueView.isHidden = !todoView.isHidden
    }
    
    func setIssueDelegate(_ viewController: IssueDelegate) {
        issueView.issueDelegate = viewController
    }
    
    @objc private func todoAddButtonTapped() {
        viewModel?.input.appendTodo.onNext(())
    }
    
    func bind(with viewModel: MainViewModel) {
        self.viewModel = viewModel
        
        todoTableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.output.repos
            .drive { [weak self] repos in
                self?.repoCollectionView.repos = repos
            }.disposed(by: disposeBag)
        
        viewModel.output.selectedRepo
            .drive{ [weak self] repoId in
                guard let self = self, let repoIndex = viewModel.selectedRepoIndex else { return }
                repoCollectionView.selectedIndex = repoIndex
                
                let color: UIColor
                if let hex = viewModel.selectedHexColor {
                    color = UIColor(hex: hex)
                } else {
                    color = .label
                }
                setSegmentedControlTintColor(color)
                setAddButtonTinkColor(color)
                
                issueViewModel.input.fetchIssue.onNext(TempRepository.getRepo(index: repoIndex))
            }.disposed(by: disposeBag)
        
        viewModel.output.todos
            .map({
                $0.sorted { !$0.isComplete || $1.isComplete }
            })
            .drive(todoTableView.rx.items(cellIdentifier: TodoCell.reuseIdentifier, cellType: TodoCell.self)) { [weak self] index, todo, cell in
                cell.selectionStyle = .none
                cell.configure(with: todo)
                cell.checkbox.rx.tapGesture()
                    .when(.recognized)
                    .subscribe(onNext: { _ in
                        self?.viewModel?.input.toggleTodo.onNext(todo.id)
                    })
                    .disposed(by: cell.disposeBag)
            }.disposed(by: disposeBag)
        
        viewModel.output.makeFirstResponder
            .drive(onNext: { [weak self] indexPath in
                guard let indexPath,
                      let cell = self?.todoTableView.cellForRow(at: indexPath) as? TodoCell else { return }
                cell.todoBecomeFirstResponder()
            }).disposed(by: disposeBag)
    }
    
    private func setSegmentedControlTintColor(_ color: UIColor) {
        let selectedAttributes = [
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .semibold)
        ]
        segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
    }
    
    private func setAddButtonTinkColor(_ color: UIColor) {
        todoAddButton.setTitleColor(color, for: .normal)
        todoAddButton.tintColor = color
    }
    
}

extension MainView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { [weak self] action, view, completionHandler in
            guard let cell = tableView.cellForRow(at: indexPath) as? TodoCell, 
                    let id = cell.viewModel?.id else { return }
            self?.viewModel?.input.deleteTodo.onNext(id)
        }
        deleteAction.backgroundColor = .systemGray4
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return configuration
    }
    
}

extension MainView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.input.selectRepoIndex.onNext(indexPath.row)
    }
}
