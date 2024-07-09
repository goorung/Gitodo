//
//  MainView.swift
//  Gitodo
//
//  Created by 이지현 on 4/25/24.
//

import UIKit

import GitodoShared

import RxCocoa
import RxSwift
import RxGesture
import SnapKit

protocol MainViewDelegate: AnyObject {
    func showMenu(from cell: MyRepoCell)
}

final class MainView: UIView {
    
    weak var delegate: MainViewDelegate?
    private var viewModel: MainViewModel?
    private let todoViewModel = TodoViewModel(localTodoService: LocalTodoService())
    private let issueViewModel = IssueViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private lazy var repoCollectionView = {
        let collectionView = MyRepoCollectionView(isEditMode: false)
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
            NSAttributedString.Key.font: UIFont.bodySB
        ]
        let selectedAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(hex: PaletteColor.blue2.hex),
            NSAttributedString.Key.font: UIFont.bodySB
        ]
        
        control.setTitleTextAttributes(normalAttributes, for: .normal)
        control.setTitleTextAttributes(selectedAttributes, for: .selected)
        
        return control
    }()
    
    private lazy var todoView = {
        let view = TodoView()
        view.bind(with: todoViewModel)
        return view
    }()
    
    private lazy var issueView = {
        let view = IssueView()
        view.bind(with: issueViewModel)
        view.isHidden = true
        return view
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setRepoLongPressGesture()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        addSubview(repoCollectionView)
        repoCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview()
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
    
    private func setRepoLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        repoCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            generateHaptic()
            let point = gestureRecognizer.location(in: repoCollectionView)
            if let indexPath = repoCollectionView.indexPathForItem(at: point) {
                guard let cell = repoCollectionView.cellForItem(at: indexPath) as? MyRepoCell else { return }
                delegate?.showMenu(from: cell)
            }
        }
    }
    
    func setIssueDelegate(_ delegate: IssueDelegate) {
        issueView.issueDelegate = delegate
    }
    
    // MARK: - Bind
    
    private func bind() {
        segmentedControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] index in
                self?.todoView.isHidden = index != 0
                self?.issueView.isHidden = index != 1
                
                if index == 1 {
                    self?.issueViewModel.input.fetchIssue.onNext(())
                }
            }).disposed(by: disposeBag)
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
                issueViewModel.input.setCurrentRepo.onNext(repo)
            }.disposed(by: disposeBag)
    }
    
    private func setSegmentedControlTintColor(_ color: UIColor) {
        let selectedAttributes = [
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: UIFont.bodySB
        ]
        segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
    }
    
}

extension MainView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        generateHaptic()
        viewModel?.input.selectRepoIndex.onNext(indexPath.row)
    }
    
}
