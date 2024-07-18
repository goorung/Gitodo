//
//  UILabel+Extension.swift
//  Gitodo
//
//  Created by 지연 on 7/9/24.
//

import UIKit

extension UILabel {
    
    func setTextWithLineHeight(_ text: String, lineHeight: CGFloat = 24.0) {
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = lineHeight
        style.maximumLineHeight = lineHeight
        
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: style
        ]
        
        let attrString = NSAttributedString(
            string: text,
            attributes: attributes
        )
        
        self.attributedText = attrString
        self.numberOfLines = 0
    }
    
}
