//
//  TodoListView.swift
//  GitodoRepoTodoWidget
//
//  Created by 이지현 on 5/24/24.
//


import WidgetKit
import SwiftUI

struct TodoListView: View {
    var body: some View {
        VStack(alignment: .leading,spacing: 13) {
            ForEach(0..<3) { _ in
                todo
            }
            completedTodo
        }
        .containerBackground(for: .widget) {}
    }
    
    var todo: some View {
        HStack(alignment: .center) {
            Image(systemName: "circle")
                .frame(width: 19, height: 19)
                .foregroundStyle(Color(uiColor: UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 1)))
            Text("할 일이 길어지면 어떻게 되는지 테스트 해보자구 어떻게")
                .font(.system(size: 13))
            Spacer()
        }
    }
    
    var completedTodo: some View {
        HStack(alignment: .center) {
            Image(systemName: "checkmark.circle")
                .frame(width: 19, height: 19)
                .foregroundStyle(Color(uiColor: UIColor(red: 204/255, green: 236/255, blue: 194/255, alpha: 1)))
            Text("할 일")
                .font(.system(size: 13))
            Spacer()
        }
    }
    
    
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
