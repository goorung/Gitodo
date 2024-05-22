//
//  RepoListWidget.swift
//  RepoListWidget
//
//  Created by jiyeon on 5/21/24.
//

import WidgetKit
import SwiftUI

import GitodoShared

struct Provider: TimelineProvider {
    let service = RepoListWidgetService()
    
    func placeholder(in context: Context) -> RepoListEntry {
        RepoListEntry(date: Date(), repos: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (RepoListEntry) -> Void) {
        let repos = (try? service.fetchTopPublicRepos()) ?? []
        let entry = RepoListEntry(date: Date(), repos: repos)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<RepoListEntry>) -> Void) {
        let repos = (try? service.fetchTopPublicRepos()) ?? []
        let entry = RepoListEntry(date: Date(), repos: repos)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct RepoListEntry: TimelineEntry {
    let date: Date
    let repos: [MyRepo]
}

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
                
                CircularProgressBar(
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

struct CircularProgressBar: View {
    var progress: Double // 0.0 to 1.0
    var lineWidth: CGFloat = 7.0
    var size: CGFloat = 50.0
    var progressColor: Color
    var trackColor: Color = Color.init(uiColor: .systemGray5)
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
        }
    }
}

struct RepoListWidget: Widget {
    let kind: String = "RepoListWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                RepoListWidgetEntryView(entry: entry)
                    .containerBackground(.background, for: .widget)
            } else {
                RepoListWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .supportedFamilies([.systemSmall]) // Small 크기만 지원
    }
}

#Preview(as: .systemSmall) {
    RepoListWidget()
} timeline: {
    RepoListEntry(date: .now, repos: [])
}
