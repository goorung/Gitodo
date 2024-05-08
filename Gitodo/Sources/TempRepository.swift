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
        Repository(
            id: 3,
            nickname: "42",
            symbol: "🤍",
            hexColor: PaletteColor.red.hex,
            todos: [
                TodoItem(todo: "inception", isComplete: false),
                TodoItem(todo: "minirt", isComplete: false),
                TodoItem(todo: "ft_irc", isComplete: true)
            ]
        ),
        Repository(
            id: 4,
            nickname: "운동",
            symbol: "💪",
            hexColor: PaletteColor.green.hex,
            todos: [
                TodoItem(todo: "달리기", isComplete: false),
                TodoItem(todo: "요가", isComplete: false),
                TodoItem(todo: "검도", isComplete: true),
                TodoItem(todo: "수영", isComplete: true)
            ]
        ),
        Repository(
            id: 5,
            nickname: "책",
            symbol: "📗",
            hexColor: PaletteColor.purple.hex,
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
    
    static func updateRepoOrder(_ repoIds: [Int]) {
        var result = [Repository]()
        for id in repoIds {
            guard let repo = repos.first(where: { $0.id == id }) else { continue }
            result.append(repo)
        }
        repos = result
    }
    
    static func todoIndex(repoIndex: Int, with id: UUID) -> Int? {
        let repo = repos[repoIndex]
        guard let firstIndex = repo.todos.firstIndex(where: { $0.id == id }) else { return nil }
        return firstIndex
    }
    
    static func countIndex(repoIndex: Int, of id: UUID) -> Int {
        guard let index = todoIndex(repoIndex: repoIndex, with: id) else { return 0 }
        var count = 0
        for i in 0..<index {
            if repos[repoIndex].todos[i].isComplete == false {
                count += 1
            }
        }
        return count
    }
    
    static func getTodos(repoIndex: Int) -> [TodoItem] {
        return repos[repoIndex].todos
    }
    
    static func appendTodo(repoIndex: Int) -> UUID {
        let todoItem = TodoItem.placeholderItem()
        repos[repoIndex].todos.append(todoItem)
        return todoItem.id
    }
    
    static func appendTodo(repoIndex: Int, after id: UUID) -> UUID? {
        guard let index = todoIndex(repoIndex: repoIndex, with: id) else { return nil}
        let todoItem = TodoItem.placeholderItem()
        repos[repoIndex].todos.insert(todoItem, at: index + 1)
        return todoItem.id
    }
    
    static func deleteTodo(repoIndex: Int, with id: UUID) {
        guard let index = todoIndex(repoIndex: repoIndex, with: id) else { return }
        repos[repoIndex].todos.remove(at: index)
    }
    
    static func toggleTodo(repoIndex: Int, with id: UUID) {
        guard let index = todoIndex(repoIndex: repoIndex, with: id) else { return }
        repos[repoIndex].todos[index].isComplete.toggle()
    }
    
    static func updateTodo(repoIndex: Int, _ newValue: TodoItem) {
        guard let index = todoIndex(repoIndex: repoIndex, with: newValue.id) else { return }
        repos[repoIndex].todos[index] = newValue
    }
    
}
