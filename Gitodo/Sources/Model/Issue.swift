//
//  Issue.swift
//  Gitodo
//
//  Created by jiyeon on 5/3/24.
//

import Foundation

struct Issue {
    let title: String
    let body: String?
    let assignees: [Assignee]?
    let labels: [Label]?
}

struct Assignee {
    let login: String
    let avatarUrl: String
}

struct Label {
    let name: String
    let color: String
}
