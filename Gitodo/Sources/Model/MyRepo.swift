//
//  Repository.swift
//  Gitodo
//
//  Created by 이지현 on 5/6/24.
//

import Foundation

struct MyRepo {
    let id: Int // github에서 가져온 id
    var nickname: String
    var fullName: String
    var symbol: String?
    var hexColor: UInt
    var todos: [TodoItem] = []
    var isPublic: Bool = false // 메인 뷰에서 공개적으로 보여질지 여부
    var isDeleted: Bool = false // 원격에서 삭제되었는지 여부
}

extension MyRepo {
    static func initItem(repository: Repository) -> Self {
        .init(id: repository.id,
              nickname: repository.name,
              fullName: repository.fullName,
              hexColor: PaletteColor.green.hex)
    }
}
