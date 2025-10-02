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



#Preview {
    NavigationView {
        AppInfoView()
    }
}
