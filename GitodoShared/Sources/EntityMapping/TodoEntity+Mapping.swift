//
//  TodoEntity+Mapping.swift
//  Gitodo
//
//  Created by 이지현 on 5/17/24.
//

import Foundation

import RealmSwift

public class TodoEntity: Object {
    @Persisted(primaryKey: true) public var id: UUID
    @Persisted public var todo: String
    @Persisted public var isComplete: Bool
    @Persisted public var order: Int
    
    @Persisted(originProperty: "todos") public var repository: LinkingObjects<RepositoryEntity>
    
    public convenience init(_ todoItem: TodoItem) {
        self.init()
        id = todoItem.id
        todo = todoItem.todo
        isComplete = todoItem.isComplete
        order = todoItem.order
    }
}

public extension TodoEntity {
    func toDomain() -> TodoItem {
        return TodoItem(
            id: id,
            todo: todo,
            isComplete: isComplete,
            order: order
        )
    }
}
