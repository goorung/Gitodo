//
//  APIManager.swift
//  Gitodo
//
//  Created by jiyeon on 5/6/24.
//

import Foundation

enum APIPath: String {
    case organization = "/user/orgs"
    case repository = "/user/repos"
}

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
    let url: String
}

final class APIManager {
    
    static let shared = APIManager() // // Singleton instance
    private init() {}
    
    // MARK: - Properties
    
    private let baseURL = "https://api.github.com"
    var accessToken = ""
    
    func fetchOrganizations() async throws -> [Organization] {
        guard let url = URL(string: baseURL + APIPath.organization.rawValue) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode([Organization].self, from: data)
    }
    
    func fetchRepositories() async throws -> [Repository] {
        guard let url = URL(string: baseURL + APIPath.repository.rawValue) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode([Repository].self, from: data)
    }
    
}
