//
//  ActionsViewModel.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//

import Foundation

@MainActor
class ActionsViewModel: ObservableObject {
    struct DebugActionsSection {
        let title: String
        let actions: [DebugAction]
    }
    
    @Published var sections: [DebugActionsSection] = []
    @Published var showingAppInfo = false
    @Published var showingInterfaceStyle = false
    
    init() {
        setupSections()
    }
    
    private func setupSections() {
        let defaultSection = DebugActionsSection(title: "Actions", actions: [
            DefaultDebugAction(title: "App Info", actionType: .appInfo),
            DefaultDebugAction(title: "Interface Style", description: "Change debug interface appearance", actionType: .interfaceStyle)
        ])
        
        sections = [
            DebugActionsSection(title: "Custom Actions", actions: DebugManager.shared.customActions),
            defaultSection
        ]
    }
    
    func handleAction(_ action: DebugAction) {
        if let action = action as? DefaultDebugAction {
            handleDefaultAction(action)
        } else if let action = action as? CustomDebugAction {
            handleCustomAction(action)
        }
    }
    
    private func handleDefaultAction(_ action: DefaultDebugAction) {
        switch action.actionType {
        case .appInfo:
            showingAppInfo = true
        case .interfaceStyle:
            showingInterfaceStyle = true
        }
    }
    
    private func handleCustomAction(_ action: CustomDebugAction) {
        action.execute()
    }
}
