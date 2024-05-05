//
//  TodoCellViewModel.swift
//  Gitodo
//
//  Created by 이지현 on 5/3/24.
//

import Foundation

class TodoCellViewModel {
    let id: UUID
    var isComplete: Bool
    var tintColorHex: UInt?
    var todo: String
    
    init(todoItem: TodoItem, tintColorHex: UInt? = nil) {
        self.id = todoItem.id
        self.isComplete = todoItem.isComplete
        self.todo = todoItem.todo
        self.tintColorHex = tintColorHex
    }
    
}
