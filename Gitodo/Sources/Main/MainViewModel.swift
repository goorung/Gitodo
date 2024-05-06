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
    
    private var tempRepo = TempRepository()
    
    struct Input {
        let reload: AnyObserver<Void>
        let appendTodo: AnyObserver<Void>
        let toggleTodo: AnyObserver<UUID>
        let deleteTodo: AnyObserver<UUID>
    }
    
    struct Output {
        var todos: Driver<[TodoCellViewModel]>
        var makeFirstResponder: Driver<IndexPath?>
    }
    
    private let reloadSubject = PublishSubject<Void>()
    private let appendTodoSubject = PublishSubject<Void>()
    private let toggleTodoSubject = PublishSubject<UUID>()
    private let deleteTodoSubject = PublishSubject<UUID>()
    private var todos = PublishRelay<[TodoCellViewModel]>()
    private var makeResponder = PublishRelay<IndexPath?>()
    private let disposeBag = DisposeBag()
    
    init() {
        input = Input(
            reload: reloadSubject.asObserver(), 
            appendTodo: appendTodoSubject.asObserver(),
            toggleTodo: toggleTodoSubject.asObserver(),
            deleteTodo: deleteTodoSubject.asObserver()
        )
        output = Output(
            todos: todos.asDriver(onErrorJustReturn: []),
            makeFirstResponder: makeResponder.asDriver(onErrorJustReturn: nil))
        
        reloadSubject.subscribe(onNext: { [weak self] in
            self?.fetchTodoList()
        })
        .disposed(by: disposeBag)
        
        appendTodoSubject.subscribe(onNext: { [weak self] in
            self?.appendTodo()
        })
        .disposed(by: disposeBag)
        
        toggleTodoSubject.subscribe(onNext: { [weak self] id in
            self?.toggleTodo(with: id)
        })
        .disposed(by: disposeBag)
        
        deleteTodoSubject.subscribe(onNext: { [weak self] id in
            self?.deleteTodo(with: id)
        })
        .disposed(by: disposeBag)
    }
    
    private func fetchTodoList() {
        
        let fetchedTodos = tempRepo.getRepo()
        
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
        let id = tempRepo.appendTodo()
        fetchTodoList()
        makeResponder.accept(IndexPath(row: tempRepo.countIndex(of: id), section: 0))
    }
    
    private func toggleTodo(with id: UUID) {
        tempRepo.toggleTodo(with: id)
        fetchTodoList()
    }
    
    
    private func deleteTodo(with id: UUID) {
        tempRepo.deleteTodo(with: id)
        fetchTodoList()
    }
    
}

class TempRepository {
    private var firstRepoTodo = [
        TodoItem(todo: "끝내주게 숨쉬기", isComplete: false),
        TodoItem(todo: "간지나게 자기", isComplete: false),
        TodoItem(todo: "작살나게 밥먹기", isComplete: false)
    ]
    
    func index(with id: UUID) -> Int? {
        guard let firstIndex = firstRepoTodo.firstIndex(where: { $0.id == id }) else { return nil }
        return firstIndex
    }
    
    func getRepo() -> [TodoItem] {
        firstRepoTodo
    }
    
    func countIndex(of id: UUID) -> Int {
        guard let index = index(with: id) else { return 0 }
        var count = 0
        for i in 0..<index {
            if firstRepoTodo[i].isComplete == false {
                count += 1
            }
        }
        return count
    }
    
    func appendTodo() -> UUID {
        let todoItem = TodoItem.placeholderItem()
        firstRepoTodo.append(todoItem)
        return todoItem.id
    }
    
    func appendTodo(after id: UUID) -> UUID? {
        guard let index = index(with: id) else { return nil }
        let todoItem = TodoItem.placeholderItem()
        firstRepoTodo.insert(todoItem, at: index + 1)
        return todoItem.id
    }
    
    func deleteTodo(with id: UUID) {
        guard let index = index(with: id) else { return }
        firstRepoTodo.remove(at: index)
    }
    
    func toggleTodo(with id: UUID) {
        guard let index = index(with: id) else { return }
        firstRepoTodo[index].isComplete.toggle()
    }
    
    func updateTodo(_ newValue: TodoItem) {
        guard let index = index(with: newValue.id) else { return }
        firstRepoTodo[index] = newValue
    }
    
}

extension MainViewModel: TodoCellViewModelDelegate {
    func todoCellViewModelDidReturnTodo(_ viewModel: TodoCellViewModel) {
        if !viewModel.todo.isEmpty {
            guard let id = tempRepo.appendTodo(after: viewModel.id) else { return }
            fetchTodoList()
            makeResponder.accept(IndexPath(row: tempRepo.countIndex(of: id), section: 0))
        }
    }
    
    func todoCellViewModel(_ viewModel: TodoCellViewModel, didEndEditingWith todo: String?) {
        if todo == nil || todo?.isEmpty == true {
            deleteTodo(with: viewModel.id)
        }
    }
    
    func todoCellViewModel(_ viewModel: TodoCellViewModel, didUpdateItem todoItem: TodoItem) {
        tempRepo.updateTodo(todoItem)
    }
}
