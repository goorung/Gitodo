//
//  LoginManager.swift
//  Gitodo
//
//  Created by jiyeon on 5/6/24.
//

import Foundation

struct Token: Codable {
    let accessToken: String
}

final class LoginManager {
    
    enum LoginPath: String {
        case login = "/authorize"
        case accessToken = "/access_token"
    }
    
    static let shared = LoginManager() // // Singleton instance
    private init() {}
    
    private let clientID = "Ov23liXtaG7W7YfAUotb"
    private let clientSecret = "0fc0289364abf389f0262ae271a7cc132afd8505"
    private let baseURL = "https://github.com/login/oauth/"
    
    func getLoginURL() -> URL? {
        var components = URLComponents(string: baseURL + LoginPath.login.rawValue)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "scope", value: "repo user read:org"),
        ]
        
        return components.url
    }
    
    func fetchAccessToken(with code: String) async throws {
        var components = URLComponents(string: baseURL + LoginPath.accessToken.rawValue)!
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
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let token = try decoder.decode(Token.self, from: data)
        
        UserDefaultsManager.accessToken = token.accessToken
    }
    
}
