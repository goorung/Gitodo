//
//  UserDefaultsManager.swift
//  Gitodo
//
//  Created by jiyeon on 5/7/24.
//

import Foundation

public struct UserDefaultsManager {
    
    @UserDefaultsData(key: "isLogin", defaultValue: false)
    public static var isLogin: Bool
    
    @UserDefaultsData(key: "isPublicRepoSet", defaultValue: false)
    public static var isPublicRepoSet: Bool
    
    @UserDefaultsData(key: "widgetSelectedRepo", defaultValue: nil)
    public static var widgetSelectedRepo: Int?
}
