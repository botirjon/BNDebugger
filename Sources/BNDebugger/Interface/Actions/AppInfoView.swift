//
//  AppInfoView.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//

import SwiftUI
import UIKit

struct AppInfoView: View {
    @StateObject private var viewModel = AppInfoViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                appIconSection
                
                appInfoSection
                
                buildInfoSection
                
                systemInfoSection
                
                deviceInfoSection
            }
            .padding(16)
        }
        .navigationTitle("App Info")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadAppInfo()
        }
    }
    
    private var appIconSection: some View {
        HStack {
            Spacer()
            
            VStack(spacing: 12) {
                if let iconImage = viewModel.appIcon {
                    Image(uiImage: iconImage)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .cornerRadius(16)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "app")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        )
                }
                
                Text(viewModel.appName)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
    }
    
    private var appInfoSection: some View {
        DetailSection(title: "App Information") {
            AppInfoItem(label: "Bundle Identifier", value: viewModel.bundleIdentifier)
            AppInfoItem(label: "Display Name", value: viewModel.displayName)
            AppInfoItem(label: "Bundle Name", value: viewModel.bundleName)
        }
    }
    
    private var buildInfoSection: some View {
        DetailSection(title: "Build Information") {
            AppInfoItem(label: "Version", value: viewModel.appVersion)
            AppInfoItem(label: "Build Number", value: viewModel.buildNumber)
            AppInfoItem(label: "Target Name", value: viewModel.targetName)
            AppInfoItem(label: "Bundle Version", value: viewModel.bundleVersion)
        }
    }
    
    private var systemInfoSection: some View {
        DetailSection(title: "System Information") {
            AppInfoItem(label: "iOS Version", value: viewModel.systemVersion)
            AppInfoItem(label: "Deployment Target", value: viewModel.deploymentTarget)
            AppInfoItem(label: "Supported Platforms", value: viewModel.supportedPlatforms)
        }
    }
    
    private var deviceInfoSection: some View {
        DetailSection(title: "Device Information") {
            AppInfoItem(label: "Device Model", value: viewModel.deviceModel)
            AppInfoItem(label: "Device Name", value: viewModel.deviceName)
            AppInfoItem(label: "System Name", value: viewModel.systemName)
        }
    }
}

struct AppInfoItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 14))
                .textSelection(.enabled)
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

#Preview {
    NavigationView {
        AppInfoView()
    }
}