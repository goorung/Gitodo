//
//  MyRepoInfoViewModel.swift
//  Gitodo
//
//  Created by 이지현 on 5/6/24.
//

import Foundation

import GitodoShared

final class MyRepoInfoViewModel {
    private(set) var repository: MyRepo
    
    init(repository: MyRepo) {
        self.repository = repository
    }
    
    var id: Int {
        repository.id
    }
    
    var name: String {
        repository.name
    }
    
    var fullName: String {
        repository.fullName
    }
    
    var nickname: String {
        get { repository.nickname }
        set { repository.nickname = newValue }
    }
    
    var symbol: String? {
        get { repository.symbol }
        set { repository.symbol = newValue }
    }
    
    var hexColor: UInt {
        get { repository.hexColor }
        set { repository.hexColor = newValue }
    }
    
    var hideCompletedTasks: Bool {
        get { repository.hideCompletedTasks }
        set { repository.hideCompletedTasks = newValue }
    }
    
    var deletionOption: DeletionOption {
        get { repository.deletionOption }
        set { repository.deletionOption = newValue }
    }
}
