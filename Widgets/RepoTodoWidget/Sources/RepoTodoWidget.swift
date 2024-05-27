//
//  RepoTodoWidget.swift
//  RepoTodoWidget
//
//  Created by jiyeon on 5/21/24.
//

import WidgetKit
import SwiftUI

import GitodoShared

struct Provider: TimelineProvider {
    let repoTodoWidgetService: RepoTodoWidgetServiceProtocol = RepoTodoWidgetService()
    
    var currentRepository: MyRepo? {
        let repoID = UserDefaultsManager.widgetSelectedRepo
        if let repo = try? repoTodoWidgetService.fetchRepo(repoID) {
            return repo
        } else {
            return nil
        }
    }
    
    var tempRepo: MyRepo? {
        guard let repos =  try? repoTodoWidgetService.fetchPublicRepos() else { return nil }
        if var repo = repos.first {
            repo.todos = repo.todos.sorted {
                $0.order < $1.order
            }
            return repo
        }
        return nil
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TodoWidgetEntry) -> Void) {
        if context.isPreview {
            return completion(TodoWidgetEntry.preview)
        }
        completion(TodoWidgetEntry(date: .now, repository: tempRepo ?? MyRepo(id: 0, name: "Gitodo", fullName: "Gitodo", ownerName: "JH713", nickname: "Gitodo", symbol: "🍀", hexColor: 0xCCECC2, todos: [])))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoWidgetEntry>) -> Void) {
        if context.isPreview {
            return completion(Timeline(entries: [TodoWidgetEntry.preview], policy: .never))
        }
        completion(Timeline(entries: [TodoWidgetEntry(date: .now, repository: tempRepo ?? MyRepo(id: 0, name: "Gitodo", fullName: "Gitodo", ownerName: "JH713", nickname: "Gitodo", symbol: "🍀", hexColor: 0xCCECC2, todos: []))], policy: .never))
    }
    
    func placeholder(in context: Context) -> TodoWidgetEntry {
        TodoWidgetEntry.preview
    }
}

struct TodoWidgetEntry: TimelineEntry {
    let date: Date
    let repository: MyRepo
    
    var mainColor: PaletteColor {
        PaletteColor.findColor(by: repository.hexColor) ?? .blue1
    }
    
    var topFourTodos: [TodoItem] {
        Array(repository.todos.sorted{ $0.order < $1.order }.prefix(4))
    }
    
    static var preview: TodoWidgetEntry {
        let demoTodos: [TodoItem] = [
            .init(todo: "위젯", isComplete: false),
            .init(todo: "배포", isComplete: false),
            .init(todo: "설명 문구", isComplete: false),
            .init(todo: "너무 길면 뒤에 점점점으로 할거임더길게", isComplete: true),
        ]
        let demoRepository = MyRepo(id: 0, name: "Gitodo", fullName: "Gitodo", ownerName: "JH713", nickname: "Gitodo", symbol: "🍀", hexColor: 0xCCECC2, todos: demoTodos)
        
        return TodoWidgetEntry(date: .now, repository: demoRepository)
    }
    
    static var current: TodoWidgetEntry {
//        let repo = 
        let todos: [TodoItem] = [
            .init(todo: "위젯", isComplete: false),
            .init(todo: "배포", isComplete: false),
            .init(todo: "설명 문구", isComplete: false),
            .init(todo: "너무 길면 뒤에 점점점으로 할거임더길게", isComplete: true),
        ]
        let demoRepository = MyRepo(id: 0, name: "Gitodo", fullName: "Gitodo", ownerName: "JH713", nickname: "Gitodo", symbol: "🍀", hexColor: 0xCCECC2, todos: todos)
        return TodoWidgetEntry(date: .now, repository: demoRepository)
    }
}

struct RepoTodoWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        HStack(spacing: 23) {
            SelectedRepoView(entry: entry)
                .frame(width: 68)
            TodoListView(entry: entry)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
        }
    }
}

struct RepoTodoWidget: Widget {
    let kind: String = "RepoTodoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RepoTodoWidgetEntryView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .supportedFamilies([.systemMedium]) // Medium 크기만 지원
    }
}

struct RepoTodoWidget_Previews: PreviewProvider {
    static var previews: some View {
        RepoTodoWidgetEntryView(entry: TodoWidgetEntry.preview)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
