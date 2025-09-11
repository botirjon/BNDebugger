//
//  InterfaceStyleView.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//

import SwiftUI
import UIKit

struct InterfaceStyleView: View {
    @StateObject private var viewModel = InterfaceStyleViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(InterfaceStyleOption.allCases, id: \.self) { option in
                        InterfaceStyleRowView(
                            option: option,
                            isSelected: viewModel.selectedStyle == option
                        ) {
                            viewModel.selectStyle(option)
                        }
                    }
                } header: {
                    Text("Choose Interface Style")
                        .font(.headline)
                } footer: {
                    Text("Select the appearance style for the debug interface. This will only affect the debug window.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current System Style")
                                .font(.system(size: 14, weight: .medium))
                            
                            Text(systemStyleDescription)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("System Information")
                        .font(.headline)
                }
            }
            .navigationTitle("Interface Style")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        viewModel.applySelectedStyle()
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                }
            }
        }
        .onAppear {
            viewModel.loadCurrentStyle()
        }
    }
    
    private var systemStyleDescription: String {
        switch UITraitCollection.current.userInterfaceStyle {
        case .light:
            return "System is currently using Light Mode"
        case .dark:
            return "System is currently using Dark Mode"
        case .unspecified:
            return "System style is unspecified"
        @unknown default:
            return "Unknown system style"
        }
    }
}

struct InterfaceStyleRowView: View {
    let option: InterfaceStyleOption
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Style icon
                Image(systemName: option.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(option.iconColor)
                    .frame(width: 30, height: 30)
                    .background(option.iconColor.opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(option.description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}



#Preview {
    InterfaceStyleView()
}
