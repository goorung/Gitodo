//
//  SelectedRepoView.swift
//  GitodoRepoTodoWidget
//
//  Created by 이지현 on 5/24/24.
//

import WidgetKit
import SwiftUI

import GitodoShared

struct SelectedRepoView: View {
    let entry: TodoWidgetEntry
    
    var body: some View {
        VStack(spacing: 13) {
            repositoryImage
            repositoryInfo
        }
        .containerBackground(for: .widget) {}
    }
    
    var repositoryImage: some View {
        ZStack {
            Circle()
                .frame(width: 65, height: 65)
                .foregroundColor(Color.init(paletteColor: entry.mainColor))
            Text(entry.repository.symbol ?? "")
                .font(.system(size: 32))
        }
    }
    
    var repositoryInfo: some View {
        VStack(alignment: .leading) {
            Text("\(entry.repository.todos.filter { !$0.isComplete }.count)")
                .font(.system(size: 18))
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundColor(Color(entry.mainColor.colorLabelName))
            Text(entry.repository.nickname)
                .font(.system(size: 17))
                .fontWeight(.bold)
                .fontDesign(.rounded)
        }
    }
}

struct SelectedRepoView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedRepoView(entry: TodoWidgetEntry.preview)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
