//
//  PaletteColor.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import Foundation

enum PaletteColor: CaseIterable {
    case red
    case yellow
    case green
    case blue
    case purple
    case gray
    
    var hex: UInt {
        switch self {
        case .red: 0xFFB5B5
        case .yellow: 0xFFEFB5
        case .green: 0xE9F8BD
        case .blue: 0xB5D3FF
        case .purple: 0xE7B5FF
        case .gray: 0xC3C3C3
        }
    }
    
    static func findIndex(_ hex: UInt) -> Int? {
        return PaletteColor.allCases.firstIndex(where: { $0.hex == hex })
    }
}
