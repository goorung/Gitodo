//
//  DeletionOptionViewModel.swift
//  Gitodo
//
//  Created by 이지현 on 7/25/24.
//

import Foundation

import GitodoShared

class DeletionOptionViewModel {
    private var deletionOption: DeletionOption
    let options = ["삭제 안 함", "바로 삭제", "매일 특정 시간 삭제", "시간 선택", "특정 시간 이후 삭제"]
    
    init(deletionOption: DeletionOption) {
        self.deletionOption = deletionOption
    }
    
}
