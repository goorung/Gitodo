//
//  MenuType.swift
//  Gitodo
//
//  Created by jiyeon on 5/4/24.
//

import Foundation

enum MainMenuType: CaseIterable {
    case repositorySettings
    case contact
    case logout
    
    var title: String {
        switch self {
        case .repositorySettings: "레포지토리 설정"
        case .contact: "문의하기"
        case .logout: "로그아웃"
        }
    }
    
    var symbol: String {
        switch self {
        case .repositorySettings: "folder"
        case .contact: "questionmark.circle"
        case .logout: "door.left.hand.open"
        }
    }
}

enum RepoMenuType: CaseIterable {
    case edit
    case hide
    
    var title: String {
        switch self {
        case .edit: "편집"
        case .hide: "숨김"
        }
    }
    
    var symbol: String {
        switch self {
        case .edit: "pencil"
        case .hide: "eye.slash"
        }
    }
}
