//
//  TodoCellViewModel.swift
//  Gitodo
//
//  Created by 이지현 on 5/3/24.
//

import Foundation

protocol TodoCellViewModelDelegate: AnyObject {
    func todoCellViewModel(_ viewModel: TodoCellViewModel, didUpdateItem: TodoItem)
    func todoCellViewModelDidReturnTodo(_ viewModel: TodoCellViewModel)
    func todoCellViewModel(_ viewModel: TodoCellViewModel, didEndEditingWith todo: String?)
}

class TodoCellViewModel {
    private var todoItem: TodoItem
    weak var delegate: TodoCellViewModelDelegate?
    
    init(todoItem: TodoItem, tintColorHex: UInt? = nil) {
        self.todoItem = todoItem
        self.tintColorHex = tintColorHex
    }
    
    var id: UUID {
        todoItem.id
    }
    
    var isComplete: Bool {
        get { todoItem.isComplete }
        set {
            todoItem.isComplete = newValue
        }
    }
    
    var statusChangedAt: Date {
        get { todoItem.statusChangedAt }
        set {
            todoItem.statusChangedAt = newValue
        }
    }
    
    var todo: String {
        get { todoItem.todo }
        set {
            todoItem.todo = newValue
            delegate?.todoCellViewModel(self, didUpdateItem: todoItem)
        }
    }
    
    func addNewTodoItem() {
        delegate?.todoCellViewModelDidReturnTodo(self)
    }

    func endEditingTodo(with todo: String?) {
        delegate?.todoCellViewModel(self, didEndEditingWith: todo)
    }
    
    var tintColorHex: UInt?
    
}
