//
//  RepoTodoWidget.swift
//  RepoTodoWidget
//
//  Created by jiyeon on 5/21/24.
//

import WidgetKit
import SwiftUI

import GitodoShared

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> TodoWidgetEntry {
        TodoWidgetEntry.preview
    }
    
    func snapshot(for configuration: RepositoryIntent, in context: Context) async -> TodoWidgetEntry {
        await todoWidgetEntry(from: configuration)
    }
    
    func timeline(for configuration: RepositoryIntent, in context: Context) async -> Timeline<TodoWidgetEntry> {
        let entries: [TodoWidgetEntry] = [
            await todoWidgetEntry(from: configuration)
        ]
        return Timeline(entries: entries, policy: .never)
    }
    
    private func todoWidgetEntry(from configuration: RepositoryIntent) async -> TodoWidgetEntry {
        do {
            let selectedRepoID = configuration.selectedRepository?.id
            let isLogin = UserDefaultsManager.isLogin
            
            print("widget: \(isLogin)")
            if let repository = try RepoTodoManager.shared.fetchRepo(selectedRepoID) {
                return TodoWidgetEntry(date: .now, isLogin: isLogin, repository: repository)
            } else {
                return TodoWidgetEntry(date: .now, isLogin: isLogin, repository: nil)
            }
        } catch {
            return TodoWidgetEntry(date: .now, isLogin: false, repository: nil)
        }
    }
}

struct TodoWidgetEntry: TimelineEntry {
    let date: Date
    let isLogin: Bool
    let repository: MyRepo?
    
    var mainColor: PaletteColor {
        if let repository {
            PaletteColor.findColor(by: repository.hexColor) ?? .blue1
        } else {
            .blue1
        }
    }
    
    var topFourTodos: [TodoItem] {
        if let repository {
            Array(repository.todos.sorted{ $0.order < $1.order }.prefix(4))
        } else {
            []
        }
    }
    
    static var preview: TodoWidgetEntry {
        let demoTodos: [TodoItem] = [
            .init(todo: "preview", isComplete: false),
            .init(todo: "preview", isComplete: false),
            .init(todo: "preview", isComplete: false),
            .init(todo: "previewpreviewpreview", isComplete: true),
        ]
        let demoRepository = MyRepo(id: 3, name: "preview", fullName: "preview", ownerName: "preview", nickname: "preview", symbol: "🍀", hexColor: 0xCCECC2, todos: demoTodos)
        
        return TodoWidgetEntry(date: .now, isLogin: true, repository: demoRepository)
    }
}

struct RepoTodoWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        if !entry.isLogin || entry.repository == nil {
            Link(destination: URL(string: "todoWidget://none")!) {
                Text("레포지토리를 불러올 수 없습니다.")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }
        } else {
            Link(destination: URL(string: "todoWidget://selectRepo?id=\(entry.repository?.id ?? 0)")!) {
                HStack(spacing: 17) {
                    SelectedRepoView(entry: entry)
                        .frame(width: 68)
                        .padding(5)
                    TodoListView(entry: entry)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                }
            }
        }
    }
}

struct RepoTodoWidget: Widget {
    let kind: String = "RepoTodoWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: RepositoryIntent.self,
            provider: Provider()
        ) { entry in
            RepoTodoWidgetEntryView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("레포지토리 투두")
        .description("선택된 레포지토리의 투두를 볼 수 있습니다.")
        .supportedFamilies([.systemMedium])
    }
}

struct RepoTodoWidget_Previews: PreviewProvider {
    static var previews: some View {
        RepoTodoWidgetEntryView(entry: TodoWidgetEntry.preview)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
