//
//  TodoItem.swift
//  Gitodo
//
//  Created by 이지현 on 5/3/24.
//

import Foundation

public struct TodoItem {
    public var id: UUID = .init()
    public var todo: String
    public var isComplete: Bool
    public var order: Int = 0
    
    public init(id: UUID = .init(), todo: String, isComplete: Bool, order: Int = 0) {
        self.id = id
        self.todo = todo
        self.isComplete = isComplete
        self.order = order
    }
    
}

public extension TodoItem {
    static func placeholderItem() -> Self {
        .init(todo: "", isComplete: false)
    }
}
