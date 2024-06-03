//
//  RepositoryEntity+Mapping.swift
//  Gitodo
//
//  Created by 이지현 on 5/17/24.
//

import Foundation

import RealmSwift

public class RepositoryEntity: Object {
    @Persisted(primaryKey: true) public var id: Int
    @Persisted public var name: String
    @Persisted public var fullName: String
    @Persisted public var ownerName: String
    @Persisted public var nickname: String
    @Persisted public var symbol: String?
    @Persisted public var hexColor: Int
    @Persisted public var todos: List<TodoEntity> = List<TodoEntity>()
    @Persisted public var isPublic: Bool = false
    @Persisted public var isDeleted: Bool = false
    @Persisted public var order: Int = 0
    
    public convenience init(_ repository: MyRepo) {
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

public extension RepositoryEntity {
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
