//
//  UserDefaultsManager.swift
//  Gitodo
//
//  Created by jiyeon on 5/7/24.
//

import Foundation

struct UserDefaultsManager {
    
    @UserDefaultsData(key: "isLogin", defaultValue: false)
    static var isLogin: Bool
    
}
