//
//  ResourcesViewModel.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 13/09/25.
//

import Foundation

@MainActor
class ResourcesViewModel: ObservableObject {
    @Published var resources: [AppResource] = []
    @Published var isLoading = false
    @Published var selectedResource: AppResource?
    
    init() {
        setupResources()
    }
    
    private func setupResources() {
        resources = ResourceType.allCases.map { AppResource(type: $0) }
    }
    
    func selectResource(_ resource: AppResource) {
        selectedResource = resource
    }
    
    // MARK: - Folder Contents Methods
    
    func getFolderContents(for resourceType: ResourceType) -> [FileItem] {
        guard let folderPath = getFolderPath(for: resourceType) else {
            return []
        }
        
        return getContentsOfDirectory(at: folderPath)
    }
    
    private func getFolderPath(for resourceType: ResourceType) -> String? {
        let fileManager = FileManager.default
        
        switch resourceType {
        case .tmpFolder:
            return NSTemporaryDirectory()
        case .documentsFolder:
            guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return nil
            }
            return documentsPath.path
        case .userDefaults:
            return nil // UserDefaults doesn't have a folder path
        }
    }
    
    private func getContentsOfDirectory(at path: String) -> [FileItem] {
        let fileManager = FileManager.default
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            return contents.compactMap { itemName in
                let itemPath = (path as NSString).appendingPathComponent(itemName)
                var isDirectory: ObjCBool = false
                
                guard fileManager.fileExists(atPath: itemPath, isDirectory: &isDirectory) else {
                    return nil
                }
                
                let attributes = try? fileManager.attributesOfItem(atPath: itemPath)
                let size = attributes?[.size] as? Int64
                let modificationDate = attributes?[.modificationDate] as? Date
                
                return FileItem(
                    name: itemName,
                    path: itemPath,
                    isDirectory: isDirectory.boolValue,
                    size: isDirectory.boolValue ? nil : size,
                    modificationDate: modificationDate
                )
            }.sorted { item1, item2 in
                if item1.isDirectory != item2.isDirectory {
                    return item1.isDirectory && !item2.isDirectory
                }
                return item1.name.localizedCaseInsensitiveCompare(item2.name) == .orderedAscending
            }
        } catch {
            print("Error reading directory contents: \(error)")
            return []
        }
    }
    
    // MARK: - UserDefaults Methods
    
    func getUserDefaultsItems() -> [UserDefaultItem] {
        let userDefaults = UserDefaults.standard
        let dictionary = userDefaults.dictionaryRepresentation()
        
        return dictionary.compactMap { key, value in
            let valueType = type(of: value)
            return UserDefaultItem(
                key: key,
                value: value,
                type: String(describing: valueType)
            )
        }.sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
    }
    
    // MARK: - File Operations
    
    func getFileContent(at path: String) -> String? {
        guard FileManager.default.fileExists(atPath: path) else {
            return nil
        }
        
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            return content
        } catch {
            // Try with other encodings if UTF-8 fails
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                if let content = String(data: data, encoding: .ascii) {
                    return content
                }
                // For binary files, show hex representation
                return data.map { String(format: "%02hhx", $0) }.joined(separator: " ")
            }
            return "Unable to read file: \(error.localizedDescription)"
        }
    }
    
    func deleteFile(at path: String) -> Bool {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: path)
            return true
        } catch {
            print("Error deleting file: \(error)")
            return false
        }
    }
    
    func getFileInfo(at path: String) -> [String: String] {
        let fileManager = FileManager.default
        var info: [String: String] = [:]
        
        do {
            let attributes = try fileManager.attributesOfItem(atPath: path)
            
            if let size = attributes[.size] as? Int64 {
                info["Size"] = ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
            }
            
            if let creationDate = attributes[.creationDate] as? Date {
                info["Created"] = DateFormatter.localizedString(from: creationDate, dateStyle: .medium, timeStyle: .short)
            }
            
            if let modificationDate = attributes[.modificationDate] as? Date {
                info["Modified"] = DateFormatter.localizedString(from: modificationDate, dateStyle: .medium, timeStyle: .short)
            }
            
            if let permissions = attributes[.posixPermissions] as? NSNumber {
                info["Permissions"] = String(format: "%o", permissions.intValue)
            }
            
            info["Path"] = path
            
        } catch {
            info["Error"] = error.localizedDescription
        }
        
        return info
    }
}
