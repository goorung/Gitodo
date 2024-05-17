//
//  LocalRepositoryService.swift
//  Gitodo
//
//  Created by 이지현 on 5/17/24.
//

import Foundation

import RealmSwift

protocol LocalRepositoryServiceProtocol {
    func fetchAllRepositories() -> [MyRepo]
}

final class LocalRepositoryService: LocalRepositoryServiceProtocol {
    func fetchAllRepositories() -> [MyRepo] {
        let realm = try! Realm()
        
        let repositoryEntities = realm.objects(RepositoryEntity.self)
        return repositoryEntities.map { $0.toDomain() }
    }
}
