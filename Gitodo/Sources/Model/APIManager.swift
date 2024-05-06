//
//  APIManager.swift
//  Gitodo
//
//  Created by jiyeon on 5/6/24.
//

import Foundation

struct TokenResponse: Codable {
    let accessToken: String
}

final class APIManager {
    
    static let shared = APIManager() // singleton
    
    private init() {}
    
    // MARK: - Properties
    
    private let clientID = "Ov23liXtaG7W7YfAUotb"
    private let clientSecret = "0fc0289364abf389f0262ae271a7cc132afd8505"
    private let urlString = "https://github.com/login/oauth/"
    private let scope = "repo read:org"
    private var accessToken: String?
    
    // MARK: - Methods
    
    func getLoginURL() -> URL? {
        var components = URLComponents(string: urlString + "authorize")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "scope", value: scope),
        ]
        
        return components.url
    }
    
    func fetchAccessToken(with code: String) async throws {
        var components = URLComponents(string: urlString + "access_token")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "code", value: code)
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let tokenResponse = try? decoder.decode(TokenResponse.self, from: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        self.accessToken = tokenResponse.accessToken
    }
    
}
