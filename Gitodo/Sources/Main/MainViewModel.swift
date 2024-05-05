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
        let deleteRow: AnyObserver<IndexPath>
    }
    
    struct Output {
        var todos: Driver<[TodoCellViewModel]>
    }
    
    
    private let reloadSubject = PublishSubject<Void>()
    private let deleteRowSubject = PublishSubject<IndexPath>()
    private var todos = PublishRelay<[TodoCellViewModel]>()
    private let disposeBag = DisposeBag()
    
    init() {
        input = Input(reload: reloadSubject.asObserver(), deleteRow: deleteRowSubject.asObserver())
        output = Output(todos: todos.asDriver(onErrorJustReturn: []))
        
        reloadSubject.subscribe(onNext: { [weak self] in
            self?.fetchTodoList()
        })
        .disposed(by: disposeBag)
        
        deleteRowSubject.subscribe(onNext: { [weak self] indexPath in
            self?.deleteTodo(at: indexPath)
        })
        .disposed(by: disposeBag)
    }
    
    private func fetchTodoList() {
        
        let fetchedTodos = tempRepo.getRepo()
        
        let todoViewModels = fetchedTodos.map{
            TodoCellViewModel(todoItem: $0, tintColorHex: 0xB5D3FF)
        }
        
        todos.accept(todoViewModels)
    }
    
//    func viewModel(at indexPath: IndexPath) -> TodoCellViewModel {
//        return viewModels[indexPath.row]
//    }
//    
//    var numberOfItems: Int {
//        viewModels.count
//    }
//    
//    func insert(_ todoItem: TodoItem, at indexPath: IndexPath) {
//        let newViewModel = TodoCellViewModel(todoItem: todoItem)
//        viewModels.insert(newViewModel, at: indexPath.row)
//    }
//    
//    func append(_ todoItem: TodoItem) {
//        insert(todoItem, at: .init(row: numberOfItems, section: 0))
//    }
//    
//    func remove(at indexPath: IndexPath) {
//        viewModels.remove(at: indexPath.row)
//    }
    
    
    private func deleteTodo(at indexPath: IndexPath) {
        tempRepo.deleteTodo(at: indexPath.row)
        fetchTodoList()
    }
    
//    func appendPlaceholderIfNeeded() -> Bool {
//        if numberOfItems == 0 {
//            append(.placeholderItem())
//            return true
//        }
//        
//        guard let lastItem = viewModels.last else { return false }
//        if !lastItem.todo.isEmpty {
//            append(.placeholderItem())
//            return true
//        }
//        return false
//    }
}

class TempRepository {
    private var firstRepoTodo = [
        TodoItem(todo: "끝내주게 숨쉬기", isComplete: false),
        TodoItem(todo: "간지나게 자기", isComplete: false),
        TodoItem(todo: "작살나게 밥먹기", isComplete: false)
    ]
    
    func getRepo() -> [TodoItem] {
        firstRepoTodo
    }
    
    func deleteTodo(at index: Int) {
        firstRepoTodo.remove(at: index)
    }
    
}
