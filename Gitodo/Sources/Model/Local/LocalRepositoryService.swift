//
//  LocalRepositoryService.swift
//  Gitodo
//
//  Created by 이지현 on 5/17/24.
//

import Foundation

import GitodoShared

import RealmSwift

protocol LocalRepositoryServiceProtocol {
    func fetchAll() throws -> [MyRepo]
    func fetchPublic() throws -> [MyRepo]
    func sync(with remoteRepos: [MyRepo]) throws
    func togglePublicStatus(of repo: MyRepo) throws
    func updateInfo(of repo: MyRepo) throws
    func updateOrder(of repos: [MyRepo]) throws
    func delete(_ repo: MyRepo) throws
    func reset() throws
}

final class LocalRepositoryService: LocalRepositoryServiceProtocol {
    
    /// Initialize Realm instance.
    private func initializeRealm() throws -> Realm {
        do {
            return try Realm()
        } catch {
            throw RealmError.initializationError(error)
        }
    }
    
    /// 모든 레포지토리 가져오기.
    func fetchAll() throws -> [MyRepo] {
        let realm = try initializeRealm()
        
        return realm.objects(RepositoryEntity.self).map { $0.toDomain() }
    }
    
    /// Public인 레포지토리 순서대로 가져오기.
    func fetchPublic() throws -> [MyRepo] {
        let realm = try initializeRealm()
        
        let repositoryEntities = realm.objects(RepositoryEntity.self)
            .where { $0.isPublic }
            .sorted(byKeyPath: "order", ascending: true)
        
        return repositoryEntities.map { $0.toDomain() }
    }
    
    /// 로컬 저장소에 저장된 repository와 원격 저장소에서 가져온 repository의 sync를 맞춤.
    func sync(with remoteRepos: [MyRepo]) throws {
        let realm = try initializeRealm()
        
        let localRepos = realm.objects(RepositoryEntity.self)
        let localRepoIDs = Set(localRepos.map { $0.id })
        let remoteRepoIDs = Set(remoteRepos.map { $0.id })

        let deletedRepos = localRepos.filter { !remoteRepoIDs.contains($0.id) }
        let newRepos = remoteRepos.filter { !localRepoIDs.contains($0.id) }
        let updatedRepos = remoteRepos.filter { localRepoIDs.contains($0.id) }

        do {
            try realm.write {
                handleDeletedRepositories(deletedRepos, realm: realm)
                addNewRepositories(newRepos, realm: realm)
                updateExistingRepositories(updatedRepos, localRepos: localRepos, realm: realm)
            }
        } catch {
            throw RealmError.syncError(error)
        }
        
    }
    
    /// 원격 저장소에서 삭제된 레포지토리가 public인 경우 삭제되었음을 표시.
    private func handleDeletedRepositories(_ deletedRepos: LazyFilterSequence<Results<RepositoryEntity>>, realm: Realm) {
        for repo in deletedRepos {
            if !repo.isDeleted {
                repo.isDeleted = true
            }
        }
    }

    /// 원격 저장소에서 가져온 새 레포지토리를 로컬 저장소에 추가.
    private func addNewRepositories(_ newRepos: [MyRepo], realm: Realm) {
        let maxOrder = getPublicMaxOrder(realm: realm)
        for (index, remoteRepo) in newRepos.enumerated() {
            let repositoryEntity = RepositoryEntity(remoteRepo)
            repositoryEntity.order = maxOrder + index + 1
            realm.add(repositoryEntity)
        }
    }

    /// 원격 저장소에 저장되어있던 레포지토리의 이름이 변경된 경우 업데이트.
    private func updateExistingRepositories(_ updatedRepos: [MyRepo], localRepos: Results<RepositoryEntity>, realm: Realm) {
        for remoteRepo in updatedRepos {
            if let localRepo = localRepos.first(where: { $0.id == remoteRepo.id }) {
                if localRepo.fullName != remoteRepo.fullName {
                    localRepo.fullName = remoteRepo.fullName
                }
            }
        }
    }
    
    /// 레포지토리의 isPublic 속성을 토글하여 업데이트.
    func togglePublicStatus(of repo: MyRepo) throws {
        let realm = try initializeRealm()
        guard let repositoryEntity = realm.object(ofType: RepositoryEntity.self, forPrimaryKey: repo.id) else {
            throw RealmError.noDataError
        }
        do {
            try realm.write {
                repositoryEntity.isPublic.toggle()
                if repositoryEntity.isPublic {
                    repositoryEntity.order = getPublicMaxOrder(realm: realm) + 1
                }
            }
        } catch {
            throw RealmError.updateError(error)
        }
        
    }
    
    /// 레포지토리 정보(nickname, symbol, hexColor)를 업데이트.
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
            }
        } catch {
            throw RealmError.updateError(error)
        }
        
    }
    
    /// 레포지토리 삭제.
    func delete(_ repo: MyRepo) throws {
        let realm = try initializeRealm()
        guard let repositoryEntity = realm.object(ofType: RepositoryEntity.self, forPrimaryKey: repo.id) else {
            throw RealmError.noDataError
        }
        
        do {
            try realm.write({
                realm.delete(repositoryEntity)
            })
        } catch {
            throw RealmError.deleteError(error)
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
    
}
