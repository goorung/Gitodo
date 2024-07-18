//
//  APIData.swift
//  Gitodo
//
//  Created by jiyeon on 5/3/24.
//

import Foundation

public struct User: Codable {
    public let login: String
    public let avatarUrl: String
}

public extension User {
    func asOrganization() -> Organization {
        return Organization(login: self.login, avatarUrl: self.avatarUrl, description: nil)
    }
}

public struct Organization: Codable {
    public let login: String
    public let avatarUrl: String
    public let description: String?
}

public struct Repository: Codable {
    public let id: Int
    public let name: String
    public let fullName: String
    public let owner: User
    public let url: String
}

public struct Issue: Codable {
    public let title: String
    public let body: String?
    public let assignees: [User]?
    public let labels: [Label]?
    public var pullRequest: PullRequest?
}

public struct Label: Codable {
    public let name: String
    public let color: String
}

public struct PullRequest: Codable {
    public let url: URL?
    public let html_url: URL?
    public let diff_url: URL?
    public let patch_url: URL?
}
