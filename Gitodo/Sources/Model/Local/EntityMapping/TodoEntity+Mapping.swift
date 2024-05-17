//
//  TodoEntity+Mapping.swift
//  Gitodo
//
//  Created by 이지현 on 5/17/24.
//

import Foundation

import RealmSwift

class TodoEntity: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var todo: String
    @Persisted var isComplete: Bool
    
    @Persisted(originProperty: "todos") var repository: LinkingObjects<RepositoryEntity>
    
    convenience init(_ todoItem: TodoItem) {
        self.init()
        id = todoItem.id
        todo = todoItem.todo
        isComplete = todoItem.isComplete
    }
}

extension TodoEntity {
    func toDomain() -> TodoItem {
        return TodoItem(
            id: id,
            todo: todo,
            isComplete: isComplete
        )
    }
}
