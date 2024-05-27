//
//  ToggleStateIntent.swift
//  GitodoRepoTodoWidget
//
//  Created by 이지현 on 5/27/24.
//

import AppIntents
import SwiftUI

struct ToggleStateIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Task State"
    
    @Parameter(title: "Todo ID")
    var id: String
    
    init() {}
    
    init(id: String) {
        self.id = id
    }
    
    func perform() async throws -> some IntentResult {
        
        guard let uuid = UUID(uuidString: id) else {
            throw NSError(domain: "Invalid UUID", code: 1)
        }
        
        try RepoTodoManager.shared.toggleCompleteStatus(of: uuid)
        return .result()
    }
}

