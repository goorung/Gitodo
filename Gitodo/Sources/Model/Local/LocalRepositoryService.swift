//
//  LocalRepositoryService.swift
//  Gitodo
//
//  Created by 이지현 on 5/17/24.
//

import Foundation

import RealmSwift

protocol LocalRepositoryServiceProtocol {
    func fetchRepositories(filter: ((Query<RepositoryEntity>) -> Query<Bool>)?) -> [MyRepo]
    func syncRepositories(_ remoteRepos: [MyRepo])
}

extension LocalRepositoryServiceProtocol {
    func fetchRepositories(filter: ((Query<RepositoryEntity>) -> Query<Bool>)? = nil) -> [MyRepo] {
        return fetchRepositories(filter: filter)
    }
}

final class LocalRepositoryService: LocalRepositoryServiceProtocol {
    func fetchRepositories(filter: ((Query<RepositoryEntity>) -> Query<Bool>)? = nil) -> [MyRepo] {
        guard let realm = try? Realm() else { return [] }
        
        var repositoryEntities = realm.objects(RepositoryEntity.self)
        
        if let filter {
            repositoryEntities = repositoryEntities.where(filter)
        }
        
        return repositoryEntities.map { $0.toDomain() }
    }
    
    
    /// 로컬 저장소에 저장된 repository와 원격 저장소에서 가져온 repository의 sync를 맞춤.
    func syncRepositories(_ remoteRepos: [MyRepo]) {
        guard let realm = try? Realm() else { return }
        
        let localRepos = realm.objects(RepositoryEntity.self)
        let localRepoIDs = Set(localRepos.map { $0.id })
        let remoteRepoIDs = Set(remoteRepos.map { $0.id })

        let deletedRepos = localRepos.filter { !remoteRepoIDs.contains($0.id) }
        let newRepos = remoteRepos.filter { !localRepoIDs.contains($0.id) }
        let updatedRepos = remoteRepos.filter { localRepoIDs.contains($0.id) }

        try! realm.write {
            handleDeletedRepositories(deletedRepos, realm: realm)
            addNewRepositories(newRepos, realm: realm)
            updateExistingRepositories(updatedRepos, localRepos: localRepos, realm: realm)
        }
        
    }
    
    /// 원격 저장소에서 삭제된 레포지토리가 public인 경우 삭제되었음을 표시하고 public이 아닌 경우 로컬 저장소에서 삭제.
    private func handleDeletedRepositories(_ deletedRepos: LazyFilterSequence<Results<RepositoryEntity>>, realm: Realm) {
        for repo in deletedRepos {
            if repo.isPublic {
                repo.isDeleted = true
            }  else {
                realm.delete(repo)
            }
        }
    }

    /// 원격 저장소에서 가져온 새 레포지토리를 로컬 저장소에 추가.
    private func addNewRepositories(_ newRepos: [MyRepo], realm: Realm) {
        for remoteRepo in newRepos {
            let repositoryEntity = RepositoryEntity(remoteRepo)
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
    
}
