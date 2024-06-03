//
//  RealmError.swift
//  Gitodo
//
//  Created by 이지현 on 5/18/24.
//

import Foundation

public enum RealmError: Error {
    case initializationError(Error)
    case noDataError
    case syncError(Error)
    case createError(Error)
    case updateError(Error)
    case deleteError(Error)
    
    public var localizedDescription: String {
        switch self {
        case .initializationError(let error):
            return "Initialization failed: \(error.localizedDescription)"
        case .noDataError:
            return "No data found."
        case .syncError(let error):
            return "Sync failed: \(error.localizedDescription)"
        case .updateError(let error):
            return "Update failed: \(error.localizedDescription)"
        case .deleteError(let error):
            return "Delete failed: \(error.localizedDescription)"
        case .createError(let error):
            return "Create failed: \(error.localizedDescription)"
        }
    }
}
