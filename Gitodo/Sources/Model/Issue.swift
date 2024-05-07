//
//  Issue.swift
//  Gitodo
//
//  Created by jiyeon on 5/3/24.
//

import Foundation

struct Issue: Codable {
    let title: String
    let body: String?
    let assignees: [User]?
    let labels: [Label]?
}

struct User: Codable {
    let login: String
    let avatarUrl: String
}

struct Label: Codable {
    let name: String
    let color: String
}
