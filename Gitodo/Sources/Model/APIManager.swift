//
//  APIManager.swift
//  Gitodo
//
//  Created by jiyeon on 5/6/24.
//

import Foundation

struct Organization: Codable {
    let login: String
    let id: Int
    let url: URL
    let avatarUrl: String
}

struct Repository: Codable {
    let id: Int
    let name: String
    let fullName: String
    let owner: Owner
    let url: String
}

struct Owner: Codable {
    let login: String
}

final class APIManager {
    
    static let shared = APIManager() // // Singleton instance
    private init() {}
    
    private let baseURL = "https://api.github.com"
    var accessToken = ""
    
    private func fetchData<T: Codable>(from url: URL?) async throws -> [T] {
        guard let url = url else {
            throw URLError(.badURL)
        }
            
        var request = URLRequest(url: url)
        request.addValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([T].self, from: data)
    }
    
    func fetchOrganization() async throws -> [Organization] {
        let url = URL(string: "\(baseURL)/user/orgs")
        return try await fetchData(from: url)
    }
    
    func fetchRepositories() async throws -> [Repository] {
        let url = URL(string: "\(baseURL)/user/repos")
        return try await fetchData(from: url)
    }
    
    func fetchIssues(for repository: Repository) async throws -> [Issue] {
        let repoName = repository.name
        let ownerName = repository.owner.login
        let url = URL(string: "\(baseURL)/repos/\(ownerName)/\(repoName)/issues")
        return try await fetchData(from: url)
    }
    
}
