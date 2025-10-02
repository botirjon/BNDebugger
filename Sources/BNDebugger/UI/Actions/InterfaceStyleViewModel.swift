//
//  InterfaceStyleViewModel.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//

import SwiftUI

enum InterfaceStyleOption: CaseIterable {
    case system
    case light
    case dark
    
    var title: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
    
    var description: String {
        switch self {
        case .system:
            return "Follow system appearance"
        case .light:
            return "Always use light appearance"
        case .dark:
            return "Always use dark appearance"
        }
    }
    
    var iconName: String {
        switch self {
        case .system:
            return "gearshape.2"
        case .light:
            return "sun.max"
        case .dark:
            return "moon"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .system:
            return .blue
        case .light:
            return .orange
        case .dark:
            return .purple
        }
    }
    
    var uiUserInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system:
            return .unspecified
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

@MainActor
class InterfaceStyleViewModel: ObservableObject {
    @Published var selectedStyle: InterfaceStyleOption = .system
    private var currentDebugWindowStyle: UIUserInterfaceStyle?
    
    func loadCurrentStyle() {
        currentDebugWindowStyle = DebugManager.shared.currentUserInterfaceStyle
        
        switch DebugManager.shared.currentUserInterfaceStyle {
        case .light:
            selectedStyle = .light
        case .dark:
            selectedStyle = .dark
        case .unspecified:
            selectedStyle = .system
        @unknown default:
            selectedStyle = .system
        }
    }
    
    func selectStyle(_ style: InterfaceStyleOption) {
        selectedStyle = style
    }
    
    func applySelectedStyle() {
        let newStyle = selectedStyle.uiUserInterfaceStyle
        DebugManager.shared.updateUserInterfaceStyle(newStyle)
    }
}
