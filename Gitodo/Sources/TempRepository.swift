//
//  TempRepository.swift
//  Gitodo
//
//  Created by 이지현 on 5/8/24.
//

import Foundation

class TempRepository {
    private init() {}
    
    static private var repos = [
        Repository(
            id: 1,
            nickname: "algorithm",
            symbol: "🪼",
            hexColor: PaletteColor.blue.hex,
            todos: [
                TodoItem(todo: "끝내주게 숨쉬기", isComplete: false),
                TodoItem(todo: "간지나게 자기", isComplete: false),
                TodoItem(todo: "작살나게 밥먹기", isComplete: false)
            ]
        ),
        Repository(
            id: 2,
            nickname: "iOS",
            symbol: "🍄",
            hexColor: PaletteColor.yellow.hex,
            todos: [
                TodoItem(todo: "1", isComplete: false),
                TodoItem(todo: "2", isComplete: false),
                TodoItem(todo: "3", isComplete: true)
            ]
        ),
    ]
    
    static func getRepos() -> [Repository] {
        repos
    }
    
    static func updateRepo(_ repo: Repository) {
        guard let index = repos.firstIndex(where: { $0.id == repo.id}) else { return }
        repos[index].nickname = repo.nickname
        repos[index].symbol = repo.symbol
        repos[index].hexColor = repo.hexColor
    }
    
    static private var firstRepoTodo = [
        TodoItem(todo: "끝내주게 숨쉬기", isComplete: false),
        TodoItem(todo: "간지나게 자기", isComplete: false),
        TodoItem(todo: "작살나게 밥먹기", isComplete: false)
    ]
    
    static func index(with id: UUID) -> Int? {
        guard let firstIndex = firstRepoTodo.firstIndex(where: { $0.id == id }) else { return nil }
        return firstIndex
    }
    
    static func getRepo() -> [TodoItem] {
        firstRepoTodo
    }
    
    static func countIndex(of id: UUID) -> Int {
        guard let index = index(with: id) else { return 0 }
        var count = 0
        for i in 0..<index {
            if firstRepoTodo[i].isComplete == false {
                count += 1
            }
        }
        return count
    }
    
    static func appendTodo() -> UUID {
        let todoItem = TodoItem.placeholderItem()
        firstRepoTodo.append(todoItem)
        return todoItem.id
    }
    
    static func appendTodo(after id: UUID) -> UUID? {
        guard let index = index(with: id) else { return nil }
        let todoItem = TodoItem.placeholderItem()
        firstRepoTodo.insert(todoItem, at: index + 1)
        return todoItem.id
    }
    
    static func deleteTodo(with id: UUID) {
        guard let index = index(with: id) else { return }
        firstRepoTodo.remove(at: index)
    }
    
    static func toggleTodo(with id: UUID) {
        guard let index = index(with: id) else { return }
        firstRepoTodo[index].isComplete.toggle()
    }
    
    static func updateTodo(_ newValue: TodoItem) {
        guard let index = index(with: newValue.id) else { return }
        firstRepoTodo[index] = newValue
    }
    
}
