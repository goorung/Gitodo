//
//  SelectedRepoView.swift
//  GitodoRepoTodoWidget
//
//  Created by 이지현 on 5/24/24.
//

import WidgetKit
import SwiftUI

struct SelectedRepoView: View {
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
                .foregroundColor(Color(uiColor: UIColor(red: 204/255, green: 236/255, blue: 194/255, alpha: 1)))
            Text("🍀")
                .font(.system(size: 32))
        }
    }
    
    var repositoryInfo: some View {
        VStack(alignment: .leading) {
            Text("3")
                .font(.system(size: 18))
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundColor(Color(uiColor: UIColor(red: 157/255, green: 195/255, blue: 147/255, alpha: 1)))
            Text("Gitodo")
                .font(.system(size: 17))
                .fontWeight(.bold)
                .fontDesign(.rounded)
        }
    }
}

struct SelectedRepoView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedRepoView()
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
