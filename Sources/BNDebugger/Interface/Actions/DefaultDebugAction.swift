//
//  DefaultDebugAction.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 10/09/25.
//

struct DefaultDebugAction: DebugAction {
    let title: String
    let description: String?
    let actionType: ActionType
    
    init(title: String, description: String? = nil, actionType: ActionType) {
        self.title = title
        self.description = description
        self.actionType = actionType
    }
    
    enum ActionType {
        case appInfo
        case showUserDefaults
        case simulateMemoryWarning
        case interfaceStyle
    }
}
