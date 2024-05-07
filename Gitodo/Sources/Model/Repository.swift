//
//  Repository.swift
//  Gitodo
//
//  Created by 이지현 on 5/6/24.
//

import Foundation

struct Repository {
    let id: Int // github에서 가져온 id
    var nickname: String
    var symbol: String?
    var hexColor: UInt
}

extension Repository {
    static func initItem(id: Int, repoName: String) -> Self {
        .init(id: id, nickname: repoName, hexColor: PaletteColor.green.hex)
    }
}
