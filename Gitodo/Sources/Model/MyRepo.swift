//
//  Repository.swift
//  Gitodo
//
//  Created by 이지현 on 5/6/24.
//

import Foundation

struct MyRepo: Hashable {
    let id: Int // github에서 가져온 id
    let name: String
    var fullName: String
    let ownerName: String
    var nickname: String
    var symbol: String?
    var hexColor: UInt
    var todos: [TodoItem] = []
    var isPublic: Bool = false // 메인 뷰에서 공개적으로 보여질지 여부
    var isDeleted: Bool = false // 원격에서 삭제되었는지 여부
    
    
    static func == (lhs: MyRepo, rhs: MyRepo) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension MyRepo {
    static func initItem(repository: Repository) -> Self {
        .init(id: repository.id,
              name: repository.name,
              fullName: repository.fullName,
              ownerName: repository.owner.login,
              nickname: repository.name,
              hexColor: PaletteColor.gray.hex)
    }
}
