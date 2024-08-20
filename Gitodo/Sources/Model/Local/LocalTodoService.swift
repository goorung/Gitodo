//
//  LocalTodoService.swift
//  Gitodo
//
//  Created by 이지현 on 5/18/24.
//

import Foundation
import WidgetKit

import GitodoShared

import RealmSwift

protocol LocalTodoServiceProtocol {
    func fetchAll(in repositoryID: Int) throws -> [TodoItem]
    func fetchUncompleted(in repositoryID: Int) throws -> [TodoItem]
    func append(_ newTodo: TodoItem, in repositoryID: Int) throws
    func append(_ newTodo: TodoItem, below todoID: UUID) throws
    func toggleCompleteStatus(of todoID: UUID) throws
    func update(_ todo: TodoItem) throws
    func delete(_ todoID: UUID) throws
    func deleteCompletedTodos(in repositoryID: Int) throws
}

final class LocalTodoService: LocalTodoServiceProtocol {
    
    /// Initialize Realm instance.
    private func initializeRealm() throws -> Realm {
        do {
            let appGroupID = "group.com.goorung.Gitodo"
            let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
            let realmURL = container?.appendingPathComponent("db.realm")
            let config = Realm.Configuration(
                fileURL: realmURL,
                schemaVersion: 1) { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    migration.enumerateObjects(ofType: RepositoryEntity.className()) { _, newObject in
                        guard let new = newObject else {return}

                        new["deletionOption"] = "none"
                        new["hideCompletedTasks"] = false
                    }
                }
            }
            return try Realm(configuration: config)
        } catch {
            throw RealmError.initializationError(error)
        }
    }
    
    /// 모든 투두 가져오기.
    func fetchAll(in repositoryID: Int) throws -> [TodoItem] {
        let realm = try initializeRealm()
        
        guard let repository = realm.object(ofType: RepositoryEntity.self, forPrimaryKey: repositoryID) else {
            throw RealmError.noDataError
        }
        
        WidgetCenter.shared.reloadAllTimelines()
        return repository.todos
            .sorted(byKeyPath: "order", ascending: true)
            .map { $0.toDomain() }
    }
    
    /// 완료되지 않은 투두 가져오기.
    func fetchUncompleted(in repositoryID: Int) throws -> [TodoItem] {
        let realm = try initializeRealm()
        
        guard let repository = realm.object(ofType: RepositoryEntity.self, forPrimaryKey: repositoryID) else {
            throw RealmError.noDataError
        }
        
        WidgetCenter.shared.reloadAllTimelines()
        return repository.todos
            .where { !$0.isComplete }
            .sorted(byKeyPath: "order", ascending: true)
            .map { $0.toDomain() }
    }
    
    /// 새로운 투두 추가
    func append(_ newTodo: TodoItem, in repositoryID: Int) throws {
        let realm = try initializeRealm()
            
        guard let repository = realm.object(ofType: RepositoryEntity.self, forPrimaryKey: repositoryID) else {
            throw RealmError.noDataError
        }
        
        let newOrder = repository.todos.filter{ !$0.isComplete }.count
        
        try append(newTodo, in: repository, at: newOrder, realm: realm)
    }
    
    /// 특정 투두 아래에 새로운 투두 추가.
    func append(_ newTodo: TodoItem, below todoID: UUID) throws {
        let realm = try initializeRealm()
            
        guard let todoEntity = realm.object(ofType: TodoEntity.self, forPrimaryKey: todoID),
              let repository = todoEntity.repository.first else {
            throw RealmError.noDataError
        }
        
        try append(newTodo, in: repository, at: todoEntity.order + 1, realm: realm)
    }
    
    /// 투두 추가 로직
    private func append(_ todo: TodoItem, in repository: RepositoryEntity, at order: Int, realm: Realm) throws {
        do {
            try realm.write {
                updateOrder(of: repository.todos, after: order - 1, offset: +1)
                let todoEntity = TodoEntity(todo)
                todoEntity.order = order
                repository.todos.append(todoEntity)
            }
        } catch {
            throw RealmError.createError(error)
        }
    }
    
    /// 투두 완료 상태 토글
    func toggleCompleteStatus(of todoID: UUID) throws {
        let realm = try initializeRealm()
        guard let todoEntity = realm.object(ofType: TodoEntity.self, forPrimaryKey: todoID),
              let todos = todoEntity.repository.first?.todos else {
            throw RealmError.noDataError
        }
        
        do {
            try realm.write {
                
                if let repo = todoEntity.repository.first,
                   DeletionOption(rawValue: repo.deletionOption).id == 1 {
                    updateOrder(of: todos, after: todoEntity.order, offset: -1)
                    realm.delete(todoEntity)
                    return
                }
                
                let destination: Int
                let incompleteCount = todos.where { !$0.isComplete }.count
                if !todoEntity.isComplete {
                    destination = incompleteCount - 1
                } else {
                    destination = incompleteCount
                }
                updateOrder(of: todos, after: todoEntity.order, offset: -1)
                updateOrder(of: todos, after: destination - 1, offset: +1)
                todoEntity.order = destination
                todoEntity.isComplete.toggle()
                todoEntity.updatedAt = .now
            }
        } catch {
            throw RealmError.updateError(error)
        }
    }
    
    /// 투두 업데이트
    func update(_ todo: TodoItem) throws {
        let realm = try initializeRealm()
        guard let todoEntity = realm.object(ofType: TodoEntity.self, forPrimaryKey: todo.id) else {
            throw RealmError.noDataError
        }
        
        do {
            try realm.write {
                todoEntity.todo = todo.todo
            }
        } catch {
            throw RealmError.updateError(error)
        }
    }
    
    /// 투두 삭제
    func delete(_ todoID: UUID) throws {
        let realm = try initializeRealm()
        guard let todoEntity = realm.object(ofType: TodoEntity.self, forPrimaryKey: todoID),
              let todos = todoEntity.repository.first?.todos else {
            throw RealmError.noDataError
        }
        
        do {
            try realm.write({
                updateOrder(of: todos, after: todoEntity.order, offset: -1)
                realm.delete(todoEntity)
            })
        } catch {
            throw RealmError.deleteError(error)
        }
    }
    
    /// 투두 순서 업데이트
    private func updateOrder(of todos: List<TodoEntity>, after order: Int, offset: Int) {
        for todo in todos {
            if todo.order > order {
                todo.order += offset
            }
        }
    }
    
    func deleteCompletedTodos(in repositoryID: Int) throws {
        let realm = try initializeRealm()
        
        guard let repository = realm.object(ofType: RepositoryEntity.self, forPrimaryKey: repositoryID) else {
            throw RealmError.noDataError
        }
        let completedTodos = repository.todos.where { $0.isComplete }
        
        do {
            try realm.write({
                realm.delete(completedTodos)
            })
        } catch {
            throw RealmError.deleteError(error)
        }
    }
    
}
