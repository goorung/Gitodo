//
//  UIFont+Extension.swift
//  Gitodo
//
//  Created by jiyeon on 5/23/24.
//

import UIKit

extension UIFont {
    
    private static let bodySize = 15.0
    private static let calloutSize = 13.0
    
    static let title = UIFont.systemFont(ofSize: 20.0, weight: .bold)
    static let title2 = UIFont.systemFont(ofSize: 18.0, weight: .bold)
    static let title3 = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
    static let title4 = UIFont.systemFont(ofSize: 15.0)
    static let smallBody = UIFont.systemFont(ofSize: 12.0)
    static let body = UIFont.systemFont(ofSize: bodySize)
    static let bodySB = UIFont.systemFont(ofSize: bodySize, weight: .semibold)
    static let bodyB = UIFont.systemFont(ofSize: bodySize, weight: .bold)
    static let callout = UIFont.systemFont(ofSize: calloutSize)
    static let calloutSB = UIFont.systemFont(ofSize: calloutSize, weight: .semibold)
    static let caption = UIFont.systemFont(ofSize: 12.0, weight: .semibold)
    static let footnote = UIFont.systemFont(ofSize: 11.0, weight: .semibold)
    
}
