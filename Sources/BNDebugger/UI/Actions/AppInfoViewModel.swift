//
//  AppInfoViewModel.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//
import SwiftUI

struct AppInfoItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            
            Group {
                if #available(iOS 15.0, *) {
                    Text(value)
                        .font(.system(size: 14))
                        .textSelection(.enabled)
                } else {
                    Text(value)
                        .font(.system(size: 14))
                }
            }
        }
    }
}

@MainActor
class AppInfoViewModel: ObservableObject {
    @Published var appIcon: UIImage?
    @Published var appName: String = ""
    @Published var bundleIdentifier: String = ""
    @Published var displayName: String = ""
    @Published var bundleName: String = ""
    @Published var appVersion: String = ""
    @Published var buildNumber: String = ""
    @Published var targetName: String = ""
    @Published var bundleVersion: String = ""
    @Published var systemVersion: String = ""
    @Published var deploymentTarget: String = ""
    @Published var supportedPlatforms: String = ""
    @Published var deviceModel: String = ""
    @Published var deviceName: String = ""
    @Published var systemName: String = ""
    
    func loadAppInfo() {
        let bundle = Bundle.main
        let infoDictionary = bundle.infoDictionary ?? [:]
        
        // App Information
        bundleIdentifier = bundle.bundleIdentifier ?? "Unknown"
        displayName = infoDictionary["CFBundleDisplayName"] as? String ?? "Unknown"
        bundleName = infoDictionary["CFBundleName"] as? String ?? "Unknown"
        appName = displayName.isEmpty ? bundleName : displayName
        
        // Build Information
        appVersion = infoDictionary["CFBundleShortVersionString"] as? String ?? "Unknown"
        buildNumber = infoDictionary["CFBundleVersion"] as? String ?? "Unknown"
        targetName = infoDictionary["CFBundleExecutable"] as? String ?? "Unknown"
        bundleVersion = infoDictionary["CFBundleInfoDictionaryVersion"] as? String ?? "Unknown"
        
        // System Information
        systemVersion = UIDevice.current.systemVersion
        deploymentTarget = infoDictionary["MinimumOSVersion"] as? String ?? "Unknown"
        
        if let platforms = infoDictionary["CFBundleSupportedPlatforms"] as? [String] {
            supportedPlatforms = platforms.joined(separator: ", ")
        } else {
            supportedPlatforms = "Unknown"
        }
        
        // Device Information
        deviceModel = UIDevice.current.model
        deviceName = UIDevice.current.name
        systemName = UIDevice.current.systemName
        
        // Load App Icon
        loadAppIcon()
    }
    
    private func loadAppIcon() {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let iconsDictionary = infoDictionary["CFBundleIcons"] as? [String: Any],
              let primaryIconDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIconDictionary["CFBundleIconFiles"] as? [String],
              let lastIcon = iconFiles.last else {
            return
        }
        
        appIcon = UIImage(named: lastIcon)
    }
}
