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
    private let todoViewModel = TodoViewModel(localTodoService: LocalTodoService())
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
    
    private lazy var todoView = {
        let view = TodoView()
        view.bind(with: todoViewModel)
        return view
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
    
    func bind(with viewModel: MainViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.repos
            .drive { [weak self] repos in
                guard let self else { return }
                self.repoCollectionView.repos = repos
                self.segmentedControl.isHidden = repos.isEmpty
                
                if repos.isEmpty {
                    self.todoView.isHidden = true
                    self.issueView.isHidden = true
                } else {
                    self.todoView.isHidden = self.segmentedControl.selectedSegmentIndex != 0
                    self.issueView.isHidden = !self.todoView.isHidden
                }

            }.disposed(by: disposeBag)
        
        viewModel.output.selectedRepo
            .drive{ [weak self] repo in
                guard let self = self, let repo else { return }
                repoCollectionView.selectedRepoId = repo.id
                
                let color = UIColor(hex: repo.hexColor)
                setSegmentedControlTintColor(color)
                todoView.setAddButtonTintColor(color)
                
                todoViewModel.input.fetchTodo.onNext(repo)
                issueViewModel.input.fetchIssue.onNext(repo)
            }.disposed(by: disposeBag)
    }
    
    private func setSegmentedControlTintColor(_ color: UIColor) {
        let selectedAttributes = [
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .semibold)
        ]
        segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
    }
    
}

extension MainView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.input.selectRepoIndex.onNext(indexPath.row)
    }
}
