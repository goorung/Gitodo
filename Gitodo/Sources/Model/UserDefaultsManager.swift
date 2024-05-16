//
//  UserDefaultsManager.swift
//  Gitodo
//
//  Created by jiyeon on 5/7/24.
//

import Foundation

struct UserDefaultsManager {
    
    @UserDefaultsData(key: "accessToken", defaultValue: "")
    static var accessToken: String
    
    @UserDefaultsData(key: "isLogin", defaultValue: false)
    static var isLogin: Bool
    
    @UserDefaultsData(key: "isFirst", defaultValue: true)
    static var isFirst: Bool
    
}
