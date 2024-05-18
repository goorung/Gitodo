//
//  APIData.swift
//  Gitodo
//
//  Created by jiyeon on 5/3/24.
//

import Foundation

struct User: Codable {
    let login: String
    let avatarUrl: String
}

struct Repository: Codable {
    let id: Int
    let name: String
    let fullName: String
    let owner: User
    let url: String
}

struct Issue: Codable {
    let title: String
    let body: String?
    let assignees: [User]?
    let labels: [Label]?
    var pullRequest: PullRequest?
}

struct Label: Codable {
    let name: String
    let color: String
}

struct PullRequest: Codable {
    let url: URL?
    let html_url: URL?
    let diff_url: URL?
    let patch_url: URL?
}
