//
//  MainViewModel.swift
//  Gitodo
//
//  Created by 이지현 on 5/3/24.
//

import Foundation

class MainViewModel {
    
    let firstRepoTodo = [
        TodoItem(todo: "끝내주게 숨쉬기", isComplete: false),
        TodoItem(todo: "간지나게 자기", isComplete: false),
        TodoItem(todo: "작살나게 밥먹기", isComplete: false)
    ]
    
    var viewModels = [TodoCellViewModel]()
    
    init() {
        viewModels = firstRepoTodo.map{
            TodoCellViewModel(todoItem: $0, tintColorHex: 0xB5D3FF)
        }
    }
    
    func viewModel(at indexPath: IndexPath) -> TodoCellViewModel {
        return viewModels[indexPath.row]
    }
    
    var numberOfItems: Int {
        viewModels.count
    }
    
    func insert(_ todoItem: TodoItem, at indexPath: IndexPath) {
        let newViewModel = TodoCellViewModel(todoItem: todoItem)
        viewModels.insert(newViewModel, at: indexPath.row)
    }
    
    func append(_ todoItem: TodoItem) {
        insert(todoItem, at: .init(row: numberOfItems, section: 0))
    }
    
    func remove(at indexPath: IndexPath) {
        viewModels.remove(at: indexPath.row)
    }
    
    func appendPlaceholderIfNeeded() -> Bool {
        if numberOfItems == 0 {
            append(.placeholderItem())
            return true
        }
        
        guard let lastItem = viewModels.last else { return false }
        if !lastItem.todo.isEmpty {
            append(.placeholderItem())
            return true
        }
        return false
    }
}
