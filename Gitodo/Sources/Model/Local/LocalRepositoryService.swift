//
//  LocalRepositoryService.swift
//  Gitodo
//
//  Created by 이지현 on 5/17/24.
//

import Foundation
import WidgetKit

import GitodoShared

import RealmSwift

protocol LocalRepositoryServiceProtocol {
    func fetchPublic() throws -> [MyRepo]
    func updateInfo(of repo: MyRepo) throws
    func updateOrder(of repos: [MyRepo]) throws
    func reset() throws
    func updateRepository(repository: Repository, isPublic: Bool) throws
    func hideRepository(_ repo: MyRepo) throws
}

final class LocalRepositoryService: LocalRepositoryServiceProtocol {
    
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
    
    /// Public인 레포지토리 순서대로 가져오기.
    func fetchPublic() throws -> [MyRepo] {
        let realm = try initializeRealm()
        
        let repositoryEntities = realm.objects(RepositoryEntity.self)
            .where { $0.isPublic }
            .sorted(byKeyPath: "order", ascending: true)
        
        return repositoryEntities.map { $0.toDomain() }
    }
    
    /// 레포지토리 정보(nickname, symbol, hexColor, hideCompletedTasks)를 업데이트.
    func updateInfo(of repo: MyRepo) throws {
        let realm = try initializeRealm()
        guard let repositoryEntity = realm.object(ofType: RepositoryEntity.self, forPrimaryKey: repo.id) else {
            throw RealmError.noDataError
        }
        do {
            try realm.write {
                repositoryEntity.nickname = repo.nickname
                repositoryEntity.symbol = repo.symbol
                repositoryEntity.hexColor = Int(repo.hexColor)
                repositoryEntity.hideCompletedTasks = repo.hideCompletedTasks
            }
        } catch {
            throw RealmError.updateError(error)
        }
        
    }
    
    /// 레포지토리 순서 변경.
    func updateOrder(of repos: [MyRepo]) throws {
        let realm = try initializeRealm()
        
        do {
            try realm.write {
                for (index, repo) in repos.enumerated() {
                    if let repositoryEntity = realm.object(ofType: RepositoryEntity.self, forPrimaryKey: repo.id) {
                        repositoryEntity.order = index
                    }
                }
            }
        } catch {
            throw RealmError.updateError(error)
        }
        
    }
    
    /// Public 레포지토리 중 가장 큰 order 가져오기.
    private func getPublicMaxOrder(realm: Realm) -> Int {
        return (realm.objects(RepositoryEntity.self)
            .where { $0.isPublic }
            .max(ofProperty: "order") as Int?) ?? -1
    }
    
    /// 모든 레포지토리 삭제
    func reset() throws {
        let realm = try initializeRealm()
        let allRepos = realm.objects(RepositoryEntity.self)
        
        do {
            try realm.write {
                realm.delete(allRepos)
            }
        } catch {
            throw RealmError.deleteError(error)
        }
    }
    
    func updateRepository(repository: Repository, isPublic: Bool) throws {
        let realm = try initializeRealm()
        
        do {
            try realm.write {
                if let existingRepo = realm.object(ofType: RepositoryEntity.self, forPrimaryKey: repository.id) {
                    // 이미 저장된 레포지토리인 경우
                    existingRepo.isPublic = isPublic
                    if isPublic {
                        existingRepo.order = getPublicMaxOrder(realm: realm) + 1
                    }
                } else if isPublic {
                    // 새로운 public 레포지토리인 경우
                    let newRepo = RepositoryEntity(MyRepo.initItem(repository: repository))
                    newRepo.isPublic = true
                    newRepo.order = getPublicMaxOrder(realm: realm) + 1
                    realm.add(newRepo)
                }
            }
        } catch {
            throw RealmError.updateError(error)
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func hideRepository(_ repo: MyRepo) throws {
        let realm = try initializeRealm()
        
        do {
            try realm.write {
                let hideRepo = realm.object(ofType: RepositoryEntity.self, forPrimaryKey: repo.id)
                hideRepo?.isPublic = false
            }
        } catch {
            throw RealmError.updateError(error)
        }
        
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
}
