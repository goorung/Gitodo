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
    case gray1
    case red2
    case yellow2
    case green2
    case blue2
    case purple2
    case gray2
    
    var hex: UInt {
        switch self {
        case .red1: 0xFFB5B5
        case .yellow1: 0xFFEFB5
        case .green1: 0xE9F8BD
        case .blue1: 0xB5D3FF
        case .purple1: 0xE7B5FF
        case .gray1: 0xC3C3C3
        case .red2: 0xFF9E9E
        case .yellow2: 0xFFE49E
        case .green2: 0xC7EBAA
        case .blue2: 0x98C2FF
        case .purple2: 0xD793F7
        case .gray2: 0xA7A2A2
        }
    }
}
