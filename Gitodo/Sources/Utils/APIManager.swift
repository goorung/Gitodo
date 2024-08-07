//
//  APIManager.swift
//  Gitodo
//
//  Created by jiyeon on 5/6/24.
//

import Foundation

import GitodoShared

enum APIError: Error {
    case invalidURL
    case noAccessToken
    case invalidResponse
    case accessTokenExpired
}

final class APIManager {
    
    static let shared = APIManager() // Singleton instance
    private init() {}
    
    private let baseURL = "https://api.github.com"
    
    private func fetchData<T: Codable>(from url: URL?) async throws -> T {
        guard let url = url else {
            throw URLError(.badURL)
        }
        
        guard let accessToken = KeychainManager.shared.read(key: "accessToken") else {
            throw APIError.noAccessToken
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        case 401: // 액세스 토큰 만료
            NotificationCenter.default.post(name: .AccessTokenDidExpire, object: nil)
            throw APIError.accessTokenExpired
        default:
            throw APIError.invalidResponse
        }
    }
    
    func fetchMe() async throws -> User {
        let url = URL(string: "\(baseURL)/user")
        return try await fetchData(from: url)
    }
    
    func fetchOrganizations(page: Int) async throws -> [Organization] {
        let url = URL(string: "\(baseURL)/user/orgs?page=\(page)")
        return try await fetchData(from: url)
    }
    
    func fetchRepositories(
        for owner: String,
        type: RepositoryFetchType,
        page: Int
    ) async throws -> [Repository] {
        var url: URL?
        switch type {
        case .organization:
            url = URL(string: "\(baseURL)/orgs/\(owner)/repos?page=\(page)")
        case .user:
            url = URL(string: "\(baseURL)/user/repos?type=owner&page=\(page)")
        }
        return try await fetchData(from: url)
    }
    
    func fetchIssues(for repo: MyRepo, page: Int) async throws -> [Issue] {
        let owner = repo.ownerName
        let repo = repo.name
        let url = URL(string: "\(baseURL)/repos/\(owner)/\(repo)/issues?per_page=6&page=\(page)")
        return try await fetchData(from: url)
    }
    
}
