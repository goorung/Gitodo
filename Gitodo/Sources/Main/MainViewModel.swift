//
//  MainViewModel.swift
//  Gitodo
//
//  Created by 이지현 on 5/3/24.
//

import Foundation

import RxCocoa
import RxSwift

final class MainViewModel {
    let input: Input
    let output: Output
    
    struct Input {
        let viewWillAppear: AnyObserver<Void>
        let selectRepoIndex: AnyObserver<Int>
        let appendTodo: AnyObserver<Void>
        let toggleTodo: AnyObserver<UUID>
        let deleteTodo: AnyObserver<UUID>
    }
    
    struct Output {
        var selectedRepo: Driver<Int?>
        var repos: Driver<[Repository]>
        var todos: Driver<[TodoCellViewModel]>
        var makeFirstResponder: Driver<IndexPath?>
    }
    
    private var selectedRepo = BehaviorRelay<Int?>(value: nil)
    private let repos = BehaviorRelay<[Repository]>(value: [])
    
    private let viewWillAppearSubject = PublishSubject<Void>()
    private let selectRepoIndexSubject = PublishSubject<Int>()
    private let appendTodoSubject = PublishSubject<Void>()
    private let toggleTodoSubject = PublishSubject<UUID>()
    private let deleteTodoSubject = PublishSubject<UUID>()
    private var todos = PublishRelay<[TodoCellViewModel]>()
    private var makeResponder = PublishRelay<IndexPath?>()
    private let disposeBag = DisposeBag()
    
    init() {
        input = Input(
            viewWillAppear: viewWillAppearSubject.asObserver(), 
            selectRepoIndex: selectRepoIndexSubject.asObserver(),
            appendTodo: appendTodoSubject.asObserver(),
            toggleTodo: toggleTodoSubject.asObserver(),
            deleteTodo: deleteTodoSubject.asObserver()
        )
        output = Output(
            selectedRepo: selectedRepo.asDriver(onErrorJustReturn: nil),
            repos: repos.asDriver(onErrorJustReturn: []),
            todos: todos.asDriver(onErrorJustReturn: []),
            makeFirstResponder: makeResponder.asDriver(onErrorJustReturn: nil))
        
        viewWillAppearSubject.subscribe(onNext: { [weak self] in
            self?.fetchRepos()
        }).disposed(by: disposeBag)
        
        selectRepoIndexSubject.subscribe(onNext: { [weak self] index in
            let id = self?.repos.value[index].id
            self?.selectedRepo.accept(id)
            self?.fetchTodoList()
        }).disposed(by: disposeBag)
        
        appendTodoSubject.subscribe(onNext: { [weak self] in
            self?.appendTodo()
        }).disposed(by: disposeBag)
        
        toggleTodoSubject.subscribe(onNext: { [weak self] id in
            self?.toggleTodo(with: id)
        }).disposed(by: disposeBag)
        
        deleteTodoSubject.subscribe(onNext: { [weak self] id in
            self?.deleteTodo(with: id)
        }).disposed(by: disposeBag)
    }
    
    var selectedRepoIndex: Int? {
        repos.value.firstIndex(where: { $0.id == selectedRepo.value })
    }
    
    var selectedHexColor: UInt? {
        guard let repoIndex = selectedRepoIndex else { return nil }
        return repos.value[repoIndex].hexColor
    }
    
    private func fetchRepos() {
        let fetchedRepos = TempRepository.getRepos()
        repos.accept(fetchedRepos)
        if selectedRepo.value == nil && fetchedRepos.count > 0 {
            selectedRepo.accept(fetchedRepos[0].id)
        } else {
            selectedRepo.accept(selectedRepo.value)
        }
        fetchTodoList()
    }
    
    private func fetchTodoList() {
        guard let repoIndex = selectedRepoIndex else { return }
        let todos = TempRepository.getTodos(repoIndex: repoIndex)
        
        let todoViewModels = todos.map{ (todoItem) -> TodoCellViewModel in
            let viewModel = TodoCellViewModel(todoItem: todoItem, tintColorHex: repos.value[repoIndex].hexColor)
            viewModel.delegate = self
            return viewModel
        }.sorted {
            return !$0.isComplete || $1.isComplete
        }
        
        self.todos.accept(todoViewModels)
    }
    
    private func appendTodo() {
        guard let repoIndex = selectedRepoIndex else { return }
        let id = TempRepository.appendTodo(repoIndex: repoIndex)
        fetchTodoList()
        makeResponder.accept(IndexPath(row: TempRepository.countIndex(repoIndex: repoIndex, of: id), section: 0))
    }
    
    private func toggleTodo(with id: UUID) {
        guard let repoIndex = selectedRepoIndex else { return }
        TempRepository.toggleTodo(repoIndex: repoIndex, with: id)
        fetchTodoList()
    }
    
    
    private func deleteTodo(with id: UUID) {
        guard let repoIndex = selectedRepoIndex else { return }
        TempRepository.deleteTodo(repoIndex: repoIndex, with: id)
        fetchTodoList()
    }
    
}

extension MainViewModel: TodoCellViewModelDelegate {
    func todoCellViewModelDidReturnTodo(_ viewModel: TodoCellViewModel) {
        if !viewModel.todo.isEmpty {
            guard let repoIndex = selectedRepoIndex else { return }
            guard let id = TempRepository.appendTodo(repoIndex: repoIndex, after: viewModel.id) else { return }
            fetchTodoList()
            makeResponder.accept(IndexPath(row: TempRepository.countIndex(repoIndex: repoIndex, of: id), section: 0))
        }
    }
    
    func todoCellViewModel(_ viewModel: TodoCellViewModel, didEndEditingWith todo: String?) {
        if todo == nil || todo?.isEmpty == true {
            deleteTodo(with: viewModel.id)
        }
    }
    
    func todoCellViewModel(_ viewModel: TodoCellViewModel, didUpdateItem todoItem: TodoItem) {
        guard let repoIndex = selectedRepoIndex else { return }
        TempRepository.updateTodo(repoIndex: repoIndex, todoItem)
    }
}
