//
//  RepoListWidgetService.swift
//  GitodoRepoListWidget
//
//  Created by jiyeon on 5/22/24.
//

import Foundation

import GitodoShared

import RealmSwift

protocol RepoListWidgetServiceProtocol {
    func fetchTopPublicRepos() throws -> [MyRepo]
}

final class RepoListWidgetService: RepoListWidgetServiceProtocol {
    
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
    
    /// Public 레포지토리를 순서대로 최대 4개 리턴
    func fetchTopPublicRepos() throws -> [MyRepo] {
        let realm = try initializeRealm()
        
        let repositoryEntities = realm.objects(RepositoryEntity.self)
            .where { $0.isPublic }
            .sorted(byKeyPath: "order", ascending: true)
        
        let topPublicRepos = repositoryEntities.prefix(4)
        
        return topPublicRepos.map { $0.toDomain() }
    }
    
}
