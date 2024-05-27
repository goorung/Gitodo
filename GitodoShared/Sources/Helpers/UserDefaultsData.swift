//
//  UserDefaultsData.swift
//  Gitodo
//
//  Created by jiyeon on 5/7/24.
//

import Foundation

@propertyWrapper
public struct UserDefaultsData<Value: Codable> {
    let key: String
    let defaultValue: Value
    var container: UserDefaults = UserDefaults(suiteName: "group.com.goorung.Gitodo") ?? .standard
    
    public var wrappedValue: Value {
        get {
            guard let data = container.object(forKey: key) as? Data else {
                return defaultValue
            }
            do {
                let value = try JSONDecoder().decode(Value.self, from: data)
                return value
            } catch {
                print("Error decoding UserDefaults data for key \(key): \(error)")
                return defaultValue
            }
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                container.set(data, forKey: key)
            } catch {
                print("Error encoding UserDefaults data for key \(key): \(error)")
            }
        }
    }
}
