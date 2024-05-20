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
    func todoCellViewModelDidBeginEditing(_ viewModel: TodoCellViewModel)
}

struct TodoIdentifierItem: Hashable {
    var id: UUID
    var isComplete: Bool
    var order: Int
    var tintColorHex: UInt?
}

class TodoCellViewModel {
    private(set) var todoItem: TodoItem
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
    
    var todo: String {
        get { todoItem.todo }
        set {
            todoItem.todo = newValue
            delegate?.todoCellViewModel(self, didUpdateItem: todoItem)
        }
    }
    
    var order: Int {
        todoItem.order
    }
    
    func beginEditing() {
        delegate?.todoCellViewModelDidBeginEditing(self)
    }
    
    func addNewTodoItem() {
        delegate?.todoCellViewModelDidReturnTodo(self)
    }

    func endEditingTodo(with todo: String?) {
        delegate?.todoCellViewModel(self, didEndEditingWith: todo)
    }
    
    var tintColorHex: UInt?
    
    var identifier: TodoIdentifierItem {
        TodoIdentifierItem(id: todoItem.id, isComplete: todoItem.isComplete, order: todoItem.order, tintColorHex: tintColorHex)
    }
    
}
