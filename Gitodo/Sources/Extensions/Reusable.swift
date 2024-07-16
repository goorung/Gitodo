//
//  Reusable.swift
//  Gitodo
//
//  Created by 지연 on 7/9/24.
//

import UIKit

protocol Reusable: AnyObject {
    
    static var reuseIdentifier: String { get }
    
}

extension Reusable {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
}
