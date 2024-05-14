//
//  PaletteColor.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import Foundation

enum PaletteColor: CaseIterable {
    case red1
    case yellow1
    case green1
    case blue1
    case purple1
    case pink1
    case red2
    case yellow2
    case green2
    case blue2
    case purple2
    case pink2
    case red3
    case yellow3
    case green3
    case blue3
    case purple3
    case pink3
    
    var hex: UInt {
        switch self {
        case .red1: 0xFFB5B5
        case .yellow1: 0xFFE4B6
        case .green1: 0xCCECC2
        case .blue1: 0xC4DCFF
        case .purple1: 0xC6C5F2
        case .pink1: 0xE2BCD8
        case .red2: 0xFA9799
        case .yellow2: 0xFFD285
        case .green2: 0xB7E1AC
        case .blue2: 0xB5D3FF
        case .purple2: 0xA6A5E6
        case .pink2: 0xD5A3C8
        case .red3: 0xF5797E
        case .yellow3: 0xFFC055
        case .green3: 0xA3D696
        case .blue3: 0x98C2FF
        case .purple3: 0x8785DA
        case .pink3: 0xC88AB8
        }
    }
    
    static func findIndex(_ hex: UInt) -> Int? {
        return PaletteColor.allCases.firstIndex(where: { $0.hex == hex })
    }
}
