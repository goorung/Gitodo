//
//  TodoListView.swift
//  GitodoRepoTodoWidget
//
//  Created by 이지현 on 5/24/24.
//


import WidgetKit
import SwiftUI

import GitodoShared

struct TodoListView: View {
    let entry: TodoWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            if entry.topFourTodos.isEmpty {
                Text("할 일이 비었어요.")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            } else {
                ForEach(0..<4, id: \.self) { index in
                    if index < entry.topFourTodos.count {
                        let todo = entry.topFourTodos[index]
                        Button(intent: ToggleStateIntent(id: todo.id.uuidString)) {
                            todoView(todo: todo)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button(action: {}) {
                            todoView(todo: TodoItem.placeholderItem())
                        }
                        .hidden()
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .containerBackground(for: .widget) {}
    }
    
    func todoView(todo: TodoItem) -> some View {
        HStack(alignment: .center) {
            Image(systemName: todo.isComplete ? "checkmark.circle" : "circle")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle( todo.isComplete ? Color(paletteColor: entry.mainColor) : Color(uiColor: UIColor.systemGray4))
            Text(todo.todo)
                .lineLimit(1)
                .font(.system(size: 13))
                .foregroundStyle(Color(uiColor: todo.isComplete ? .secondaryLabel : .label))
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
    
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView(entry: TodoWidgetEntry.preview)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
