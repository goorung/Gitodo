//
//  KeychainManager.swift
//  Gitodo
//
//  Created by jiyeon on 5/13/24.
//

import Foundation
import Security

final class KeychainManager {
    
    static let shared = KeychainManager()
    private init() {}
    
    private let service = Bundle.main.bundleIdentifier ?? "com.goorung.Gitodo"
    private let account = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Gitodo"
    
    // Create or Update
    func save(key: String, data: String) {
        if read(key: key) != nil {
            update(key: key, data: data)
        } else {
            let dataToSave = data.data(using: .utf8)!
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecAttrGeneric as String: key,
                kSecValueData as String: dataToSave
            ]
            
            SecItemDelete(query as CFDictionary)
            SecItemAdd(query as CFDictionary, nil)
        }
    }
    
    // Read
    func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrGeneric as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue!
        ]
        
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == noErr, let data = item as? Data, let result = String(data: data, encoding: .utf8) {
            return result
        }
        
        return nil
    }
    
    // Update
    func update(key: String, data: String) {
        let newData = data.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrGeneric as String: key
        ]
        let attributes: [String: Any] = [kSecValueData as String: newData]
        
        SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    }
    
    // Delete
    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrGeneric as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
}
