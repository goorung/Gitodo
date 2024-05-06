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
    let assignees: [Assignee]?
    let labels: [Label]?
}

struct Assignee: Codable {
    let login: String
    let avatarUrl: String
}

struct Label: Codable {
    let name: String
    let color: String
}
