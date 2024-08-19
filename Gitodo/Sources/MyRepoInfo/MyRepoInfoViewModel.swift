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
    
    var deletionOptionText: String {
        switch deletionOption {
        case .none:
            return "삭제 안 함"
        case .immediate:
            return "바로 삭제"
        case .scheduledDaily(let hour, let minute):
            let minuteText = minute < 10 ? "0\(minute)":"\(minute)"
            if hour == 0 {
                return "매일 오전 12:\(minuteText)"
            } else if hour < 12 {
                return "매일 오전 \(hour):\(minuteText)"
            } else if hour == 12 {
                return "매일 오후 12:\(minuteText)"
            } else {
                return "매일 오후 \(hour - 12):\(minuteText)"
            }
            // FIXME: 특정 시간 이후 문구 시간에 맞게 수정하기
        case .afterDuration(let duration):
            return "1시간 후"
        }
    }
}
