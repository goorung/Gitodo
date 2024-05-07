//
//  TodoItem.swift
//  Gitodo
//
//  Created by 이지현 on 5/3/24.
//

import Foundation

struct TodoItem {
    var id: UUID = .init()
    var todo: String
    var isComplete: Bool
}

extension TodoItem {
    static func placeholderItem() -> Self {
        .init(todo: "", isComplete: false)
    }
}
