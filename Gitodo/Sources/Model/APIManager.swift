//
//  APIManager.swift
//  Gitodo
//
//  Created by jiyeon on 5/6/24.
//

import Foundation

import GitodoShared

final class APIManager {
    
    static let shared = APIManager() // Singleton instance
    private init() {}
    
    private let baseURL = "https://api.github.com"
    
    private func fetchData<T: Codable>(from url: URL?) async throws -> T {
        guard let url = url else {
            throw URLError(.badURL)
        }
        
        guard let accessToken = KeychainManager.shared.read(key: "accessToken") else {
            throw URLError(.userAuthenticationRequired)
        }
            
        var request = URLRequest(url: url)
        request.addValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        case 401: // 액세스 토큰 만료
            NotificationCenter.default.post(name: .AccessTokenDidExpire, object: nil)
            throw URLError(.userAuthenticationRequired)
        default:
            throw URLError(.badServerResponse)
        }
    }
    
    func fetchMe() async throws -> User {
        let url = URL(string: "\(baseURL)/user")
        return try await fetchData(from: url)
    }
    
    func fetchRepositories() async throws -> [Repository] {
        let url = URL(string: "\(baseURL)/user/repos?per_page=100")
        return try await fetchData(from: url)
    }
    
    func fetchIssues(for repo: MyRepo) async throws -> [Issue] {
        let repoName = repo.name
        let ownerName = repo.ownerName
        let url = URL(string: "\(baseURL)/repos/\(ownerName)/\(repoName)/issues?per_page=100")
        return try await fetchData(from: url)
    }
    
}
