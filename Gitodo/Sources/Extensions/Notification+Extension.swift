//
//  Notification+Extension.swift
//  Gitodo
//
//  Created by jiyeon on 5/4/24.
//

import Foundation

extension Notification.Name {
    
    static let AccessTokenFetchDidStart = Notification.Name("AccessTokenFetchDidStart")
    static let AccessTokenFetchDidEnd = Notification.Name("AccessTokenFetchDidEnd")
    static let AssigneeCollectionViewHeightDidUpdate = Notification.Name("AssigneeCollectionViewHeightDidUpdate")
    static let LabelCollectionViewHeightDidUpdate = Notification.Name("LabelCollectionViewHeightDidUpdate")
    static let RepositoryOrderDidUpdate = Notification.Name("RepositoryOrderDidUpdate")
    static let AccessTokenDidExpire = Notification.Name("AccessTokenDidExpire")
    
}
