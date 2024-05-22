//
//  RepoListWidgetEntryView.swift
//  GitodoRepoListWidget
//
//  Created by jiyeon on 5/22/24.
//

import SwiftUI

struct RepoListWidgetEntryView: View {
    var entry: RepoListEntry
    
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            if entry.repos.isEmpty {
                Text("No Repositories")
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            } else {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(entry.repos) { repo in
                        RepoView(repo: repo)
                    }
                }
            }
        }
    }
}
