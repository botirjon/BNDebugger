//
//  UserDefaultsViewModel.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//

import SwiftUI

struct UserDefaultsEntry {
    let key: String
    let value: Any
    let type: String
    let displayValue: String
}

class UserDefaultsViewModel: ObservableObject {
    @Published var userDefaultsEntries: [UserDefaultsEntry] = []
    @Published var isLoading = false
    @Published var showingClearAlert = false
    
    func loadUserDefaults() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let entries = self.extractUserDefaults()
            
            DispatchQueue.main.async {
                self.userDefaultsEntries = entries
                self.isLoading = false
            }
        }
    }
    
    func refreshUserDefaults() {
        loadUserDefaults()
    }
    
    func deleteEntry(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        loadUserDefaults()
    }
    
    func clearAllUserDefaults() {
        let domain = Bundle.main.bundleIdentifier ?? "com.unknown"
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        loadUserDefaults()
    }
    
    private func extractUserDefaults() -> [UserDefaultsEntry] {
        let userDefaults = UserDefaults.standard
        let dictionary = userDefaults.dictionaryRepresentation()
        
        var entries: [UserDefaultsEntry] = []
        
        for (key, value) in dictionary {
            // Skip system keys that start with common prefixes
            if shouldSkipSystemKey(key) {
                continue
            }
            
            let entry = UserDefaultsEntry(
                key: key,
                value: value,
                type: getTypeString(for: value),
                displayValue: formatValue(value)
            )
            entries.append(entry)
        }
        
        return entries.sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
    }
    
    private func shouldSkipSystemKey(_ key: String) -> Bool {
        let systemPrefixes = [
            "NS", "Apple", "WebKit", "AK", "CA", "UI", "CG", "CF", "kCF",
            "com.apple", "PKKeychainVersionKey", "AddingEmojiKeybordHandled"
        ]
        
        return systemPrefixes.contains { key.hasPrefix($0) }
    }
    
    private func getTypeString(for value: Any) -> String {
        switch value {
        case is String:
            return "String"
        case is Int, is Int32, is Int64:
            return "Integer"
        case is Float, is Double:
            return "Number"
        case is Bool:
            return "Boolean"
        case is Data:
            return "Data"
        case is [String]:
            return "Array<String>"
        case is [Any]:
            return "Array"
        case is [String: Any]:
            return "Dictionary"
        default:
            return "Unknown"
        }
    }
    
    private func formatValue(_ value: Any) -> String {
        switch value {
        case let stringValue as String:
            return stringValue
        case let numberValue as NSNumber:
            if CFGetTypeID(numberValue) == CFBooleanGetTypeID() {
                return numberValue.boolValue ? "true" : "false"
            } else {
                return numberValue.stringValue
            }
        case let dataValue as Data:
            if let string = String(data: dataValue, encoding: .utf8) {
                return string
            } else {
                return "<Data: \(dataValue.count) bytes>"
            }
        case let arrayValue as [Any]:
            do {
                let data = try JSONSerialization.data(withJSONObject: arrayValue, options: [.prettyPrinted])
                return String(data: data, encoding: .utf8) ?? "\(arrayValue)"
            } catch {
                return "\(arrayValue)"
            }
        case let dictValue as [String: Any]:
            do {
                let data = try JSONSerialization.data(withJSONObject: dictValue, options: [.prettyPrinted])
                return String(data: data, encoding: .utf8) ?? "\(dictValue)"
            } catch {
                return "\(dictValue)"
            }
        default:
            return "\(value)"
        }
    }
}
