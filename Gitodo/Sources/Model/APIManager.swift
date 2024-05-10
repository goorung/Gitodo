//
//  APIManager.swift
//  Gitodo
//
//  Created by jiyeon on 5/6/24.
//

import Foundation

final class APIManager {
    
    static let shared = APIManager() // Singleton instance
    private init() {}
    
    private let baseURL = "https://api.github.com"
    
    private func fetchData<T: Codable>(from url: URL?) async throws -> T {
        guard let url = url else {
            throw URLError(.badURL)
        }
            
        var request = URLRequest(url: url)
        request.addValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.addValue("token \(UserDefaultsManager.accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
    
    func fetchMe() async throws -> User {
        let url = URL(string: "\(baseURL)/user")
        return try await fetchData(from: url)
    }
    
    func fetchOrganization() async throws -> [Organization] {
        let url = URL(string: "\(baseURL)/user/orgs")
        return try await fetchData(from: url)
    }
    
    func fetchRepositories() async throws -> [Repository] {
        let url = URL(string: "\(baseURL)/user/repos")
        return try await fetchData(from: url)
    }
    
    func fetchIssues(for repo: MyRepo) async throws -> [Issue] {
        let repoName = repo.name
        let ownerName = repo.ownerName
        let url = URL(string: "\(baseURL)/repos/\(ownerName)/\(repoName)/issues")
        print(url)
        return try await fetchData(from: url)
    }
    
}
