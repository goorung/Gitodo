//
//  TodoViewModel.swift
//  Gitodo
//
//  Created by 이지현 on 5/17/24.
//

import Foundation

import GitodoShared

import RxCocoa
import RxRelay
import RxSwift

enum TodoSection: CaseIterable {
    case main
}

final class TodoViewModel: BaseViewModel {
    
    struct Input {
        let fetchTodo: AnyObserver<MyRepo>
        let appendTodo: AnyObserver<Void>
        let toggleTodo: AnyObserver<UUID>
        let deleteTodo: AnyObserver<UUID>
    }
    
    struct Output {
        var todos: Driver<[TodoCellViewModel]>
        var makeFirstResponder: Driver<IndexPath?>
        var resignFirstResponder: Driver<IndexPath?>
    }
    
    var disposeBag = DisposeBag()
    
    // MARK: - Properties
    
    let input: Input
    let output: Output
    
    private let fetchTodoSubject = PublishSubject<MyRepo>()
    private let appendTodoSubject = PublishSubject<Void>()
    private let toggleTodoSubject = PublishSubject<UUID>()
    private let deleteTodoSubject = PublishSubject<UUID>()
    
    private var todos = BehaviorRelay<[TodoCellViewModel]>(value: [])
    private var makeFirstResponder = PublishRelay<IndexPath?>()
    private var resignFirstResponder = PublishRelay<IndexPath?>()
    
    var selectedRepo: MyRepo?
    var firstResponderIndexPath: IndexPath?
    var lastResponderIndexPath: IndexPath? 
    
    var todoViewModels = [UUID: TodoCellViewModel]()
    
    private let localTodoService: LocalTodoServiceProtocol
    
    // MARK: - Initializer
    
    init(localTodoService: LocalTodoServiceProtocol) {
        self.localTodoService = localTodoService
        input = Input(
            fetchTodo: fetchTodoSubject.asObserver(),
            appendTodo: appendTodoSubject.asObserver(),
            toggleTodo: toggleTodoSubject.asObserver(),
            deleteTodo: deleteTodoSubject.asObserver()
        )
        output = Output(
            todos: todos
                .observe(on: MainScheduler.asyncInstance)
                .asDriver(onErrorJustReturn: []),
            makeFirstResponder: makeFirstResponder
                .observe(on: MainScheduler.asyncInstance)
                .asDriver(onErrorJustReturn: nil),
            resignFirstResponder: resignFirstResponder
                .observe(on: MainScheduler.asyncInstance)
                .asDriver(onErrorJustReturn: nil)
        )
        
        bindInputs()
    }
    
    func bindInputs() {
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
        do {
            let todos = try localTodoService.fetchAll(in: repo.id)
            
            let viewModels = todos
                .map { (todoItem) -> TodoCellViewModel in
                    let newViewModel: TodoCellViewModel
                    if let viewModel = todoViewModels[todoItem.id] {
                        newViewModel = viewModel
                        newViewModel.setTodoItem(todoItem: todoItem)
                        newViewModel.tintColorHex = repo.hexColor
                    } else {
                        newViewModel = TodoCellViewModel(todoItem: todoItem, tintColorHex: repo.hexColor)
                        todoViewModels[newViewModel.id] = newViewModel
                    }
                    newViewModel.delegate = self
                    return newViewModel
                }
            self.todos.accept(viewModels)
        } catch {
            logError(in: "fetchTodos", error)
        }
        
    }
    
    private func appendTodo() {
        do {
            guard let repo = selectedRepo else { return }
            try localTodoService.append(.placeholderItem(), in: repo.id)
            fetchTodos()
            let rowIndex = todos.value.filter { !$0.isComplete }.count - 1
            makeFirstResponder.accept(IndexPath(row: rowIndex, section: 0))
        } catch {
            logError(in: "appendTodo", error)
        }
        
    }
    
    private func appendTodo(after todo: TodoItem) {
        do {
            try localTodoService.append(.placeholderItem(), below: todo.id)
            fetchTodos()
            makeFirstResponder.accept(IndexPath(row: todo.order + 1, section: 0))
        } catch {
            logError(in: "appendTodo", error)
        }
        
    }
    
    private func toggleTodo(with id: UUID) {
        do {
            try localTodoService.toggleCompleteStatus(of: id)
            
            if let lastResponderIndexPath,
               todos.value[safe: lastResponderIndexPath.row]?.todo.isEmpty == true {
                resignFirstResponder.accept(lastResponderIndexPath)
                return
            }
            fetchTodos()
        } catch {
            logError(in: "toggleTodo", error)
        }
    }
    
    private func deleteTodo(with id: UUID) {
        do {
            try localTodoService.delete(id)
            todoViewModels.removeValue(forKey: id)
            fetchTodos()
        } catch {
            logError(in: "deleteTodo", error)
        }
    }
    
    private func logError(in functionName: String, _ error: Error) {
        print("[TodoViewModel] \(functionName) failed : \(error.localizedDescription)")
    }
    
    func viewModel(at indexPath: IndexPath) -> TodoCellViewModel {
        todos.value[indexPath.row]
    }
    
}

extension TodoViewModel: TodoCellViewModelDelegate {
    
    func todoCellViewModelDidBeginEditing(_ viewModel: TodoCellViewModel) {
        firstResponderIndexPath = IndexPath(row: viewModel.order, section: 0)
        lastResponderIndexPath = firstResponderIndexPath
    }
    
    func todoCellViewModelDidReturnTodo(_ viewModel: TodoCellViewModel) {
        if !viewModel.todo.isEmpty {
            appendTodo(after: viewModel.todoItem)
        }
    }
    
    func todoCellViewModel(_ viewModel: TodoCellViewModel, didEndEditingWith todo: String?) {
        if viewModel.order == firstResponderIndexPath?.row {
            firstResponderIndexPath = nil
        }
        
        if todo == nil || todo?.isEmpty == true {
            deleteTodo(with: viewModel.id)
        } else {
            fetchTodos()
        }
    }
    
    func todoCellViewModel(_ viewModel: TodoCellViewModel, didUpdateItem todoItem: TodoItem) {
        do {
            try localTodoService.update(todoItem)
        } catch {
            logError(in: "didUpdateItem", error)
        }
    }
    
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return self.indices ~= index ? self[index] : nil
    }
}
