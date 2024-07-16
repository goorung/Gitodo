//
//  IssueState.swift
//  Gitodo
//
//  Created by 지연 on 7/10/24.
//

import Foundation

enum IssueState {
    
    case hasIssues
    case noIssues
    case repoDeleted
    case noInternetConnection
    case error
    
    var message: String? {
        switch self {
        case .hasIssues:            nil
        case .noIssues:             "생성된 이슈가 없습니다 🫥"
        case .repoDeleted:          "원격 저장소에서 삭제된 레포지토리입니다 👻"
        case .noInternetConnection: "네트워크 연결이 필요합니다 🌐"
        case .error:                "문제가 발생했습니다.\n잠시 후 다시 시도해주세요!"
        }
    }
    
}
