//
//  RepoTodoManager.swift
//  GitodoRepoTodoWidget
//
//  Created by 이지현 on 5/25/24.
//

import Foundation

import GitodoShared

import RealmSwift

final class RepoTodoManager {
    static let shared = RepoTodoManager()
    
    private init() {}
    
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
    
    func fetchPublicRepos() throws -> [MyRepo] {
        let realm = try initializeRealm()
        
        let repositoryEntities = realm.objects(RepositoryEntity.self)
            .where { $0.isPublic }
            .sorted(byKeyPath: "order", ascending: true)
        
        return repositoryEntities.map { $0.toDomain() }
    }
    
    func fetchRepo(_ id: Int?) throws -> MyRepo? {
        guard let id else { return nil }
        let realm = try initializeRealm()
        
        guard let repositoryEntity = realm.object(ofType: RepositoryEntity.self, forPrimaryKey: id) else {
            return nil
        }
        
        if let deletionTime = calculateDeletionTime(for: DeletionOption(rawValue: repositoryEntity.deletionOption)) {
            let todosToDelete = repositoryEntity.todos
                .filter { $0.isComplete && $0.updatedAt <= deletionTime }
            do {
                try realm.write {
                    realm.delete(todosToDelete)
                }
            }
            catch {
                throw RealmError.deleteError(error)
            }
        }
        
        return repositoryEntity.toDomain()
    }
    
    ///  삭제 시간 계산
    private func calculateDeletionTime(for option: DeletionOption) -> Date? {
        let now = Date()
        let calendar = Calendar.current
        
        switch option {
        case .scheduledDaily(let hour, let minute):
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
            components.hour = hour
            components.minute = minute
            if let deletionTime = calendar.date(from: components), now < deletionTime {
                return calendar.date(byAdding: .day, value: -1, to: deletionTime)
            }
            return calendar.date(from: components)
        case .afterDuration(let duration):
            switch duration {
            case .hours(let hours):
                return calendar.date(byAdding: .hour, value: -hours, to: now)
            case .days(let days):
                return calendar.date(byAdding: .day, value: -days, to: now)
            case .weeks(let weeks):
                return calendar.date(byAdding: .day, value: -weeks * 7, to: now)
            }
        default:
            return nil
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
                   DeletionOption(rawValue: repo.deletionOption).id == 1,
                   !todoEntity.isComplete {
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
    
    /// 투두 순서 업데이트
    private func updateOrder(of todos: List<TodoEntity>, after order: Int, offset: Int) {
        for todo in todos {
            if todo.order > order {
                todo.order += offset
            }
        }
    }
    
}
