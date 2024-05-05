//
//  MainView.swift
//  Gitodo
//
//  Created by 이지현 on 4/25/24.
//

import UIKit

import SnapKit

class MainView: UIView {
    
    let viewModel = MainViewModel()
    
    private lazy var repoCollectionView = RepoCollectionView()
    
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
            NSAttributedString.Key.foregroundColor: UIColor(hex: PaletteColor.blue.hex),
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
        view.dataSource = self
        view.delegate = self
        view.register(TodoCell.self, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        view.keyboardDismissMode = .interactive
        return view
    }()
    
    private lazy var todoAddButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), for: .normal)
        button.setTitle(" 할 일 추가", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.tintColor = .init(hex: PaletteColor.blue.hex)
        button.setTitleColor(.init(hex: PaletteColor.blue.hex), for: .normal)
//        button.addTarget(self, action: #selector(todoAddButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var issueView = {
        let view = UIView()
        view.backgroundColor = .green
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
    
//    @objc private func todoAddButtonTapped() {
//        tempTodo.append((isComplete: false, todo: ""))
//        let indexPath = IndexPath(row: tempTodo.count - 1, section: 0)
//        todoTableView.insertRows(at: [indexPath], with: .automatic)
//        if let cell = todoTableView.cellForRow(at: indexPath) as? TodoCell {
//            cell.todoBecomeFirstResponder()
//            todoTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//        }
//    }
}

extension MainView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = todoTableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifier, for: indexPath) as? TodoCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.configure(with: viewModel.viewModel(at: indexPath))
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { [weak self] action, view, completionHandler in
            self?.viewModel.remove(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteAction.backgroundColor = .systemGray4
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return configuration
    }
    
}
