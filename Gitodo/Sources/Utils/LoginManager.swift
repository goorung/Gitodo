//
//  LoginManager.swift
//  Gitodo
//
//  Created by jiyeon on 5/6/24.
//

import Foundation

final class LoginManager {
    
    static let shared = LoginManager() // Singleton instance
    private init() {}
    
    private var clientID: String {
        return Bundle.main.object(forInfoDictionaryKey: "CLIENT_ID") as? String ?? ""
    }
    
    private var clientSecret: String {
        return Bundle.main.object(forInfoDictionaryKey: "CLIENT_SECRET") as? String ?? ""
    }
    
    private let baseURL = "https://github.com/login/oauth"
    
    func getLoginURL() -> URL? {
        var components = URLComponents(string: "\(baseURL)/authorize")
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "scope", value: "repo user read:org"),
        ]
        
        return components?.url
    }
    
    func fetchAccessToken(with code: String) async throws {
        var components = URLComponents(string: "\(baseURL)/access_token")
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "code", value: code)
        ]
        
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let token = try decoder.decode(Token.self, from: data)
        
        KeychainManager.shared.save(key: "accessToken", data: token.accessToken)
    }
    
    func deleteAccessToken() {
        KeychainManager.shared.delete(key: "accessToken")
    }

}
