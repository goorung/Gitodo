//
//  LocalTodoService.swift
//  Gitodo
//
//  Created by 이지현 on 5/18/24.
//

import Foundation

import RealmSwift

protocol LocalTodoServiceProtocol {
    func fetchAll(in repositoryID: Int) throws -> [TodoItem]
    func create(_ todo: TodoItem, for repositoryID: Int) throws
    func toggleCompleteStatus(of todoID: UUID) throws
    func update(_ todo: TodoItem) throws
    func delete(_ todoID: UUID) throws
}

final class LocalTodoService: LocalTodoServiceProtocol {
    
    /// Initialize Realm instance.
    private func initializeRealm() throws -> Realm {
        do {
            return try Realm()
        } catch {
            throw RealmError.initializationError(error)
        }
    }
    
    /// 모든 투두 가져오기
    func fetchAll(in repositoryID: Int) throws -> [TodoItem] {
        let realm = try initializeRealm()
        
        guard let repository = realm.object(ofType: RepositoryEntity.self, forPrimaryKey: repositoryID) else {
            throw RealmError.noDataError
        }
        
        return repository.todos.map { $0.toDomain() }
    }
    
    func create(_ todo: TodoItem, for repositoryID: Int) throws {
        let realm = try initializeRealm()
        
        do {
            try realm.write {
                guard let repository = realm.object(ofType: RepositoryEntity.self, forPrimaryKey: repositoryID) else {
                    throw RealmError.noDataError
                }
                let todoEntity = TodoEntity(todo)
                repository.todos.append(todoEntity)
            }
        } catch {
            throw RealmError.createError(error)
        }
        
    }
    
    func toggleCompleteStatus(of todoID: UUID) throws {
        let realm = try initializeRealm()
        guard let todoEntity = realm.object(ofType: TodoEntity.self, forPrimaryKey: todoID) else {
            throw RealmError.noDataError
        }
        do {
            try realm.write {
                todoEntity.isComplete.toggle()
                todoEntity.statusChangedAt = Date()
            }
        } catch {
            throw RealmError.updateError(error)
        }
    }
    
    func update(_ todo: TodoItem) throws {
        let realm = try initializeRealm()
        guard let todoEntity = realm.object(ofType: TodoEntity.self, forPrimaryKey: todo.id) else {
            throw RealmError.noDataError
        }
        
        do {
            try realm.write({
                todoEntity.todo = todo.todo
            })
        } catch {
            throw RealmError.deleteError(error)
        }
    }
    
    func delete(_ todoID: UUID) throws {
        let realm = try initializeRealm()
        guard let todoEntity = realm.object(ofType: TodoEntity.self, forPrimaryKey: todoID) else {
            throw RealmError.noDataError
        }
        
        do {
            try realm.write({
                realm.delete(todoEntity)
            })
        } catch {
            throw RealmError.deleteError(error)
        }
    }
    
}
