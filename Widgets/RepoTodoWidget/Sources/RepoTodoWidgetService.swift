//
//  RepoTodoWidgetService.swift
//  GitodoRepoTodoWidget
//
//  Created by 이지현 on 5/25/24.
//

import Foundation

import GitodoShared

import RealmSwift

protocol RepoTodoWidgetServiceProtocol {
    func fetchPublicRepos() throws -> [MyRepo]
    func fetchRepo(_ id: Int?) throws -> MyRepo?
    func toggleCompleteStatus(of todoID: UUID) throws
//    func fetchAllTodos() throws -> [TodoItem]?
}

final class RepoTodoWidgetService: RepoTodoWidgetServiceProtocol {
    
    /// Initialize Realm instance.
    private func initializeRealm() throws -> Realm {
        do {
            let appGroupID = "group.com.goorung.Gitodo"
            let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
            let realmURL = container?.appendingPathComponent("db.realm")
            let config = Realm.Configuration(fileURL: realmURL)
            return try Realm(configuration: config)
        } catch {
            throw RealmError.initializationError(error)
        }
    }
    
    func fetchPublicRepos() throws -> [MyRepo] {
        let realm = try initializeRealm()
        
        let repositoryEntities = realm.objects(RepositoryEntity.self)
            .where { $0.isPublic }
            .sorted(byKeyPath: "order", ascending: true)
        
        return repositoryEntities.map { $0.toDomain() }
    }
    
    func fetchRepo(_ id: Int?) throws -> MyRepo? {
        let realm = try initializeRealm()
        
        guard let repositoryEntity = realm.object(ofType: RepositoryEntity.self, forPrimaryKey: id) else {
            return nil
        }
        
        return repositoryEntity.toDomain()
    }
    
//    func fetchAllTodos() throws -> [TodoItem]? {
//        let realm = try initializeRealm()
//        
//        let repositoryEntities = realm.objects(RepositoryEntity.self)
//            .where { $0.isPublic }
//            .sorted(byKeyPath: "order", ascending: true)
//        
//        let topPublicRepos = repositoryEntities.prefix(4)
//        
//        let todoEntities = realm.objects(TodoEntity.self) else {
//            return nil
//        }
//    }
    
    /// 투두 완료 상태 토글
    func toggleCompleteStatus(of todoID: UUID) throws {
        let realm = try initializeRealm()
        guard let todoEntity = realm.object(ofType: TodoEntity.self, forPrimaryKey: todoID),
              let todos = todoEntity.repository.first?.todos else {
            throw RealmError.noDataError
        }
        
        do {
            try realm.write {
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
            }
        } catch {
            throw RealmError.updateError(error)
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
    
}
