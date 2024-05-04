//
//  MainView.swift
//  Gitodo
//
//  Created by 이지현 on 4/25/24.
//

import UIKit

import SnapKit

class MainView: UIView {
    
    let tempTodo = [
        (isComplete: false, todo: "알고리즘 풀기"),
        (isComplete: false, todo: "iOS 공부"),
        (isComplete: false, todo: "IRC"),
        (isComplete: false, todo: "webserv"),
        (isComplete: true, todo: "CPP"),
        (isComplete: true, todo: "inception"),
    ]
    
    let tempIssue = [
        Issue(title: "title", body: "body\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nbody\n\n\n\n\n\n\n\n\n\n\n\n\n\nbody", assignees: [Assignee(login: "login0", avataUrl: ""), Assignee(login: "login1", avataUrl: ""), Assignee(login: "login2", avataUrl: ""), Assignee(login: "login3", avataUrl: ""), Assignee(login: "login4", avataUrl: ""), Assignee(login: "login5", avataUrl: ""), Assignee(login: "login6", avataUrl: ""), Assignee(login: "login7", avataUrl: ""), Assignee(login: "login8", avataUrl: ""), Assignee(login: "login9", avataUrl: "")], labels: [Label(name: "✨ enhancement", color: "BFD4F2")]),
        Issue(title: "title", body: "body\nbody\nbody", assignees: [Assignee(login: "login", avataUrl: "")], labels: [Label(name: "🐛 bug", color: "E99695"), Label(name: "🪐 build", color: "D4C5F9"), Label(name: "📋 documentation", color: "C2E0C6"), Label(name: "✨ enhancement", color: "BFD4F2"), Label(name: "🛠️ refactoring", color: "FEF2C0")]),
        Issue(title: "title\ntitle\ntitle", body: "body", assignees: [Assignee(login: "login", avataUrl: "")], labels: [Label(name: "✨ enhancement", color: "BFD4F2")])
    ]
    
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
            NSAttributedString.Key.foregroundColor: UIColor.systemMint,
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
        return view
    }()
    
    private lazy var todoAddButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), for: .normal)
        button.setTitle(" 할 일 추가", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        button.tintColor = .systemMint
        button.setTitleColor(.systemMint, for: .normal)
        return button
    }()
    
    private lazy var issueView = {
        let view = IssueTableView()
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
            make.leading.trailing.bottom.equalToSuperview()
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
        if !issueView.isHidden {
            issueView.configure(with: tempIssue)
        }
    }
    
    func setIssueDelegate(_ viewController: IssueDelegate) {
        issueView.issueDelegate = viewController
    }
}

extension MainView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tempTodo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = todoTableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifier, for: indexPath) as? TodoCell else { return UITableViewCell() }
        let todo = tempTodo[indexPath.row]
        cell.selectionStyle = .none
        cell.configure(isComplete: todo.isComplete, todo: todo.todo, color: .systemMint)
        return cell
    }
    
    
}
