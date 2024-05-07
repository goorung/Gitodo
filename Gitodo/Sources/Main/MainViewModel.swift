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
        let appendTodo: AnyObserver<Void>
        let toggleTodo: AnyObserver<UUID>
        let deleteTodo: AnyObserver<UUID>
    }
    
    struct Output {
        var repos: Driver<[Repository]>
        var todos: Driver<[TodoCellViewModel]>
        var makeFirstResponder: Driver<IndexPath?>
    }
    
    private let repos = PublishRelay<[Repository]>()
    
    private let viewWillAppearSubject = PublishSubject<Void>()
    private let appendTodoSubject = PublishSubject<Void>()
    private let toggleTodoSubject = PublishSubject<UUID>()
    private let deleteTodoSubject = PublishSubject<UUID>()
    private var todos = PublishRelay<[TodoCellViewModel]>()
    private var makeResponder = PublishRelay<IndexPath?>()
    private let disposeBag = DisposeBag()
    
    init() {
        input = Input(
            viewWillAppear: viewWillAppearSubject.asObserver(), 
            appendTodo: appendTodoSubject.asObserver(),
            toggleTodo: toggleTodoSubject.asObserver(),
            deleteTodo: deleteTodoSubject.asObserver()
        )
        output = Output(
            repos: repos.asDriver(onErrorJustReturn: []),
            todos: todos.asDriver(onErrorJustReturn: []),
            makeFirstResponder: makeResponder.asDriver(onErrorJustReturn: nil))
        
        viewWillAppearSubject.subscribe(onNext: { [weak self] in
            self?.fetchRepos()
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
    
    private func fetchRepos() {
        let fetchedRepos = TempRepository.getRepos()
        repos.accept(fetchedRepos)
    }
    
    private func fetchTodoList() {
        
        let fetchedTodos = TempRepository.getRepo()
        
        let todoViewModels = fetchedTodos.map{ (todoItem) -> TodoCellViewModel in
            let viewModel = TodoCellViewModel(todoItem: todoItem, tintColorHex: 0xB5D3FF)
            viewModel.delegate = self
            return viewModel
        }.sorted {
            return !$0.isComplete || $1.isComplete
        }
        
        todos.accept(todoViewModels)
    }
    
    private func appendTodo() {
        let id = TempRepository.appendTodo()
        fetchTodoList()
        makeResponder.accept(IndexPath(row: TempRepository.countIndex(of: id), section: 0))
    }
    
    private func toggleTodo(with id: UUID) {
        TempRepository.toggleTodo(with: id)
        fetchTodoList()
    }
    
    
    private func deleteTodo(with id: UUID) {
        TempRepository.deleteTodo(with: id)
        fetchTodoList()
    }
    
}

extension MainViewModel: TodoCellViewModelDelegate {
    func todoCellViewModelDidReturnTodo(_ viewModel: TodoCellViewModel) {
        if !viewModel.todo.isEmpty {
            guard let id = TempRepository.appendTodo(after: viewModel.id) else { return }
            fetchTodoList()
            makeResponder.accept(IndexPath(row: TempRepository.countIndex(of: id), section: 0))
        }
    }
    
    func todoCellViewModel(_ viewModel: TodoCellViewModel, didEndEditingWith todo: String?) {
        if todo == nil || todo?.isEmpty == true {
            deleteTodo(with: viewModel.id)
        }
    }
    
    func todoCellViewModel(_ viewModel: TodoCellViewModel, didUpdateItem todoItem: TodoItem) {
        TempRepository.updateTodo(todoItem)
    }
}
