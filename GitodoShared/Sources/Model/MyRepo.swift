//
//  Repository.swift
//  Gitodo
//
//  Created by 이지현 on 5/6/24.
//

import Foundation

public struct MyRepo: Hashable {
    public let id: Int // github에서 가져온 id
    public let name: String
    public var fullName: String
    public let ownerName: String
    public var nickname: String
    public var symbol: String?
    public var hexColor: UInt
    public var todos: [TodoItem] = []
    public var isPublic: Bool = false // 메인 뷰에서 공개적으로 보여질지 여부
    public var isDeleted: Bool = false // 원격에서 삭제되었는지 여부
    
    
    public static func == (lhs: MyRepo, rhs: MyRepo) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public extension MyRepo {
    static func initItem(repository: Repository) -> Self {
        .init(id: repository.id,
              name: repository.name,
              fullName: repository.fullName,
              ownerName: repository.owner.login,
              nickname: repository.name,
              hexColor: PaletteColor.blue2.hex)
    }
}
