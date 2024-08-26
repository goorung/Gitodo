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
    case invalidResponse(statusCode: Int)
    case accessTokenExpired
    case decodingError(Error)
}

final class APIManager {
    
    static let shared = APIManager()
    private init() {}
    
    private let baseURL = "https://api.github.com"
    
    private func createURL(endpoint: String, queryItems: [URLQueryItem] = []) -> URL? {
        var components = URLComponents(string: baseURL + endpoint)
        components?.queryItems = queryItems
        return components?.url
    }
    
    private func createRequest(url: URL) throws -> URLRequest {
        guard let accessToken = KeychainManager.shared.read(key: "accessToken") else {
            throw APIError.noAccessToken
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func handleResponse<T: Codable>(_ data: Data, _ response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(statusCode: 0)
        }
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        case 401:
            NotificationCenter.default.post(name: .AccessTokenDidExpire, object: nil)
            throw APIError.accessTokenExpired
        default:
            throw APIError.invalidResponse(statusCode: httpResponse.statusCode)
        }
    }
    
    private func fetchData<T: Codable>(
        endpoint: String,
        queryItems: [URLQueryItem] = []
    ) async throws -> T {
        guard let url = createURL(endpoint: endpoint, queryItems: queryItems) else {
            throw APIError.invalidURL
        }
        
        let request = try createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        return try handleResponse(data, response)
    }
    
    func fetchMe() async throws -> User {
        return try await fetchData(endpoint: "/user")
    }
    
    func fetchOrganizations(page: Int) async throws -> [Organization] {
        return try await fetchData(
            endpoint: "/user/orgs",
            queryItems: [URLQueryItem(name: "page", value: String(page))]
        )
    }
    
    func fetchRepositories(
        for owner: String,
        type: RepositoryFetchType,
        page: Int
    ) async throws -> [Repository] {
        let endpoint: String
        switch type {
        case .organization:
            endpoint = "/orgs/\(owner)/repos"
        case .user:
            endpoint = "/user/repos"
        }
        
        let queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "type", value: type == .user ? "owner" : nil)
        ].compactMap { $0 }
        
        return try await fetchData(endpoint: endpoint, queryItems: queryItems)
    }
    
    func fetchIssues(for repo: MyRepo, page: Int) async throws -> [Issue] {
        let endpoint = "/repos/\(repo.ownerName)/\(repo.name)/issues"
        return try await fetchData(
            endpoint: endpoint,
            queryItems: [URLQueryItem(name: "page", value: String(page))]
        )
    }
}
