//
//  RepoListEntry.swift
//  GitodoRepoListWidget
//
//  Created by jiyeon on 5/22/24.
//

import WidgetKit

import GitodoShared

struct RepoListEntry: TimelineEntry {
    let date: Date
    let repos: [MyRepo]
}
