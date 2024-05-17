//
//  RepositoryEntity+Mapping.swift
//  Gitodo
//
//  Created by 이지현 on 5/17/24.
//

import Foundation

import RealmSwift

class RepositoryEntity: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var fullName: String
    @Persisted var ownerName: String
    @Persisted var nickname: String
    @Persisted var symbol: String?
    @Persisted var hexColor: Int
    @Persisted var todos: List<TodoEntity> = List<TodoEntity>()
    @Persisted var isPublic: Bool = false
    @Persisted var isDeleted: Bool = false
    
    convenience init(_ repository: MyRepo) {
        self.init()
        id = repository.id
        name = repository.name
        fullName = repository.fullName
        ownerName = repository.ownerName
        nickname = repository.nickname
        symbol = repository.symbol
        hexColor = Int(repository.hexColor)
        let realmTodoList = List<TodoEntity>()
        let todoEntities = repository.todos.map({ TodoEntity($0) })
        realmTodoList.append(objectsIn: todoEntities)
        todos = realmTodoList
        isPublic = repository.isPublic
        isDeleted = repository.isDeleted
    }
}

extension RepositoryEntity {
    func toDomain() -> MyRepo {
        return MyRepo(
            id: id,
            name: name,
            fullName: fullName,
            ownerName: ownerName,
            nickname: nickname,
            symbol: symbol,
            hexColor: UInt(hexColor),
            todos: todos.map{ $0.toDomain() },
            isPublic: isPublic,
            isDeleted: isDeleted
        )
    }
}
