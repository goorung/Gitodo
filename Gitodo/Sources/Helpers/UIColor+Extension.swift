//
//  UIColor+Extension.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit

extension UIColor {
    
    convenience init(hex: UInt) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    private static func color(light: UIColor, dark: UIColor) -> UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return dark
            default:
                return light
            }
        }
    }
    
    static let background = color(light: .white, dark: UIColor(hex: 0x242424))
    
}
