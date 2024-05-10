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
        MyRepo(
            id: 1,
            nickname: "algorithm",
            fullName: "goorung/algorithm",
            symbol: "🪼",
            hexColor: PaletteColor.blue.hex,
            todos: [
                TodoItem(todo: "끝내주게 숨쉬기", isComplete: false),
                TodoItem(todo: "간지나게 자기", isComplete: false),
                TodoItem(todo: "작살나게 밥먹기", isComplete: false)
            ],
            isPublic: true
        ),
        MyRepo(
            id: 3,
            nickname: "42",
            fullName: "goorung/42",
            symbol: "🤍",
            hexColor: PaletteColor.red.hex,
            todos: [
                TodoItem(todo: "inception", isComplete: false),
                TodoItem(todo: "minirt", isComplete: false),
                TodoItem(todo: "ft_irc", isComplete: true)
            ],
            isPublic: true
        ),
    ]
    
    static func getRepos() -> [MyRepo] {
        repos
    }
    
    static func syncRepos(_ fetchedRepos: [MyRepo]) {
        let repoIDs = Set(repos.map { $0.id })
        let fetchedRepoIDs = Set(fetchedRepos.map { $0.id })
        
        // 원격에서 삭제된 레포지토리 처리
        let deletedIDs = repoIDs.subtracting(fetchedRepoIDs)
        deletedIDs.forEach { id in
            markAsDeleted(id)
        }
        
        // 새로운 레포지토리 추가 및 이름 변경된 레포지토리 업데이트
        for fetchedRepo in fetchedRepos {
            if let index = repos.firstIndex(where: { $0.id == fetchedRepo.id }) {
                // 이름이 변경되었는지 확인 후 업데이트
                if repos[index].fullName != fetchedRepo.fullName {
                    repos[index].fullName = fetchedRepo.fullName
                }
            } else {
                // 새 레포지토리 추가
                repos.append(fetchedRepo)
            }
        }
    }
    
    static func togglePublic(_ id: Int?) {
        if let index = repos.firstIndex(where: { $0.id == id }) {
            repos[index].isPublic.toggle()
        }
    }
    
    static func markAsDeleted(_ id: Int) {
        if let index = repos.firstIndex(where: { $0.id == id }) {
            repos[index].isDeleted = true
        }
    }
    
    static func removeRepo(_ id: Int) {
        guard let index = repos.firstIndex(where: { $0.id == id}) else { return }
        repos.remove(at: index)
    }
    
    static func updateRepoInfo(_ repo: MyRepo) {
        guard let index = repos.firstIndex(where: { $0.id == repo.id}) else { return }
        repos[index].nickname = repo.nickname
        repos[index].symbol = repo.symbol
        repos[index].hexColor = repo.hexColor
    }
    
    static func updateRepoOrder(_ repoIds: [Int]) {
        var result = [MyRepo]()
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
