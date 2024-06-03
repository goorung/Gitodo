//
//  RepoView.swift
//  GitodoRepoListWidget
//
//  Created by jiyeon on 5/22/24.
//

import SwiftUI

import GitodoShared

struct RepoView: View {
    let repo: MyRepo
    let progress: Double
    
    init(repo: MyRepo) {
        self.repo = repo
        if repo.todos.count == 0 {
            self.progress = 0.0
        } else {
            self.progress = Double(repo.todos.filter { $0.isComplete }.count) / Double(repo.todos.count)
        }
    }
    
    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(Color.init(hex: repo.hexColor))
                    .opacity(0.3)
                    .overlay {
                        Text(repo.symbol ?? "")
                            .font(.title2)
                    }
                
                CircularProgressBarView(
                    progress: progress,
                    progressColor: Color.init(hex: repo.hexColor)
                )
            }
            .frame(width: 50, height: 50)
            
            Text(repo.nickname)
                .font(.system(size: 8.0, weight: .bold))
                .foregroundStyle(.primary)
                .frame(width: 50)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}

