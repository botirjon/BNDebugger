//
//  ResourceModels.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 13/09/25.
//

import Foundation

enum ResourceType: String, CaseIterable {
    case tmpFolder = "tmp"
    case documentsFolder = "documents"
    case userDefaults = "userDefaults"
    
    var displayName: String {
        switch self {
        case .tmpFolder:
            return "Temp Folder"
        case .documentsFolder:
            return "Documents Folder"
        case .userDefaults:
            return "UserDefaults"
        }
    }
    
    var systemIconName: String {
        switch self {
        case .tmpFolder:
            return "folder.fill"
        case .documentsFolder:
            return "document.fill"
        case .userDefaults:
            return "gearshape.2.fill"
        }
    }
    
    var description: String {
        switch self {
        case .tmpFolder:
            return "Temporary files and cache data"
        case .documentsFolder:
            return "App documents and user data"
        case .userDefaults:
            return "App preferences and settings"
        }
    }
}

struct AppResource: Identifiable {
    let id = UUID()
    let type: ResourceType
    let title: String
    let description: String
    let iconName: String
    
    init(type: ResourceType) {
        self.type = type
        self.title = type.displayName
        self.description = type.description
        self.iconName = type.systemIconName
    }
}

struct FileItem: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    let isDirectory: Bool
    let size: Int64?
    let modificationDate: Date?
    
    var displaySize: String {
        guard let size = size, !isDirectory else { return "" }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

struct UserDefaultItem: Identifiable {
    let id = UUID()
    let key: String
    let value: Any
    let type: String
    
    var displayValue: String {
        switch value {
        case let stringValue as String:
            return "\"\(stringValue)\""
        case let numberValue as NSNumber:
            return numberValue.stringValue
        case let arrayValue as [Any]:
            return "Array(\(arrayValue.count) items)"
        case let dictValue as [String: Any]:
            return "Dictionary(\(dictValue.count) keys)"
        case let dataValue as Data:
            return "Data(\(dataValue.count) bytes)"
        default:
            return String(describing: value)
        }
    }
}
