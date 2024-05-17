//
//  TodoViewModel.swift
//  Gitodo
//
//  Created by 이지현 on 5/17/24.
//

import Foundation

import RxCocoa
import RxRelay
import RxSwift

final class TodoViewModel {
    let input: Input
    let output: Output
    
    struct Input {
        let fetchTodo: AnyObserver<MyRepo>
        let appendTodo: AnyObserver<Void>
        let toggleTodo: AnyObserver<UUID>
        let deleteTodo: AnyObserver<UUID>
    }
    
    struct Output {
        var todos: Driver<[TodoCellViewModel]>
        var makeFirstResponder: Driver<IndexPath?>
    }
    
    private let fetchTodoSubject = PublishSubject<MyRepo>()
    private let appendTodoSubject = PublishSubject<Void>()
    private let toggleTodoSubject = PublishSubject<UUID>()
    private let deleteTodoSubject = PublishSubject<UUID>()
    private var todos = BehaviorRelay<[TodoCellViewModel]>(value: [])
    private var makeFirstResponder = PublishRelay<IndexPath?>()
    private let disposeBag = DisposeBag()
    
    var selectedRepo: MyRepo?
    
    init() {
        input = Input(
            fetchTodo: fetchTodoSubject.asObserver(),
            appendTodo: appendTodoSubject.asObserver(),
            toggleTodo: toggleTodoSubject.asObserver(),
            deleteTodo: deleteTodoSubject.asObserver()
        )
        output = Output(
            todos: todos.asDriver(onErrorJustReturn: []),
            makeFirstResponder: makeFirstResponder.asDriver(onErrorJustReturn: nil)
        )
        
        fetchTodoSubject.subscribe(onNext: {[weak self] repo in
            self?.selectedRepo = repo
            self?.fetchTodos()
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
    
    private func fetchTodos() {
        guard let repo = selectedRepo else { return }
        let todos = TempRepository.getTodos(repoId: repo.id)
        
        let todoViewModels = todos.map{ (todoItem) -> TodoCellViewModel in
            let viewModel = TodoCellViewModel(todoItem: todoItem, tintColorHex: repo.hexColor)
            viewModel.delegate = self
            return viewModel
        }
        
        self.todos.accept(todoViewModels)
    }
    
    private func appendTodo() {
        guard let repo = selectedRepo,
              let id = TempRepository.appendTodo(repoId: repo.id) else { return }
        fetchTodos()
        let sortedTodos = todos.value.sorted {
            if $0.isComplete == $1.isComplete {
                return $0.statusChangedAt < $1.statusChangedAt
            }
            return !$0.isComplete && $1.isComplete
        }
        guard let rowIndex = sortedTodos.firstIndex(where: { id == $0.id }) else { return }
        makeFirstResponder.accept(IndexPath(row: rowIndex, section: 0))
    }
    
    private func toggleTodo(with id: UUID) {
        guard let repo = selectedRepo else { return }
        TempRepository.toggleTodo(repoId: repo.id, with: id)
        fetchTodos()
    }
    
    
    private func deleteTodo(with id: UUID) {
        guard let repo = selectedRepo else { return }
        TempRepository.deleteTodo(repoId: repo.id, with: id)
        fetchTodos()
    }
}

extension TodoViewModel: TodoCellViewModelDelegate {
    func todoCellViewModelDidReturnTodo(_ viewModel: TodoCellViewModel) {
        if !viewModel.todo.isEmpty {
            appendTodo()
        }
    }
    
    func todoCellViewModel(_ viewModel: TodoCellViewModel, didEndEditingWith todo: String?) {
        if todo == nil || todo?.isEmpty == true {
            deleteTodo(with: viewModel.id)
        }
    }
    
    func todoCellViewModel(_ viewModel: TodoCellViewModel, didUpdateItem todoItem: TodoItem) {
        guard let repo = selectedRepo else { return }
        TempRepository.updateTodo(repoId: repo.id, todoItem)
    }
}
