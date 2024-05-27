//
//  AppIntent.swift
//  GitodoRepoTodoWidget
//
//  Created by 이지현 on 5/27/24.
//

import AppIntents
import SwiftUI

import GitodoShared

struct SelectedRepo: AppEntity {
    let id: Int
    let title: String
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "레포지토리"
    static var defaultQuery = SelectedRepoQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
}

struct SelectedRepoQuery: EntityQuery {
    func entities(for identifiers: [SelectedRepo.ID]) async throws -> [SelectedRepo] {
        if let repo = try RepoTodoManager.shared.fetchRepo(identifiers.first) {
            return [SelectedRepo(id: repo.id, title: repo.nickname)]
        }
        return []
    }
    
    func suggestedEntities() async throws -> [SelectedRepo] {
        try RepoTodoManager.shared.fetchPublicRepos().map {
            SelectedRepo(id: $0.id, title: $0.nickname)
        }
    }
    
    func defaultResult() async -> SelectedRepo? {
        try? RepoTodoManager.shared.fetchPublicRepos().map {
            SelectedRepo(id: $0.id, title: $0.nickname)
        }.first
    }
}

struct RepositoryIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "레포지토리"
    static var description = IntentDescription("위젯에서 보여줄 레포지토리를 선택하세요.")

    @Parameter(title: "레포지토리")
    var selectedRepository: SelectedRepo?
}
