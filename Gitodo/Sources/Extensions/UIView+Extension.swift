//
//  UIView+Extension.swift
//  Gitodo
//
//  Created by jiyeon on 5/21/24.
//

import UIKit

extension UIView {
    
    func generateHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
}
