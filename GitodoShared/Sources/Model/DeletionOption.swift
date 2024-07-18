//
//  DeletionOption.swift
//  GitodoShared
//
//  Created by 이지현 on 7/18/24.
//

import Foundation

public enum DeletionOption {
    case none
    case immediate
    case scheduledDaily(time: Int)
    case afterDuration(Duration)
    
    public enum Duration {
        case hours(Int)
        case days(Int)
        case weeks(Int)
    }
}

extension DeletionOption {
    var rawValue: String {
        switch self {
        case .none:
            return "none"
        case .immediate:
            return "immediate"
        case .scheduledDaily(let time):
            return "scheduledDaily:\(time)"
        case .afterDuration(let duration):
            return "afterDuration:\(duration.rawValue)"
        }
    }
    
    init(rawValue: String) {
        let components = rawValue.split(separator: ":").map(String.init)
        switch components[0] {
        case "none":
            self = .none
        case "immediate":
            self = .immediate
        case "scheduledDaily":
            if let hour = Int(components[1]) {
                self = .scheduledDaily(time: hour)
            } else {
                self = .none
            }
        case "afterDuration":
            let duration = String(components.dropFirst().joined(separator: ":"))
            if let parsedDuration = Duration(rawValue: duration) {
                self = .afterDuration(parsedDuration)
            } else {
                self = .none
            }
        default:
            self = .none
        }
    }
}

extension DeletionOption.Duration {
    var rawValue: String {
        switch self {
        case .hours(let hours):
            return "hours:\(hours)"
        case .days(let days):
            return "days:\(days)"
        case .weeks(let weeks):
            return "weeks:\(weeks)"
        }
    }
    
    init?(rawValue: String) {
        let components = rawValue.split(separator: ":").map(String.init)
        guard components.count >= 2,
              let value = Int(components[1]) else { return nil }
        
        switch components[0] {
        case "hours":
            self = .hours(value)
        case "days":
            self = .days(value)
        case "weeks":
            self = .weeks(value)
        default:
            return nil
        }
    }
}
