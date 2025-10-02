//
//  ActionsView.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//

import SwiftUI

struct ActionsView: View {
    @StateObject private var viewModel = ActionsViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.sections, id: \.title) { section in
                Section {
                    ForEach(section.actions, id: \.title) { action in
                        ActionRowView(action: action) {
                            viewModel.handleAction(action)
                        }
                    }
                } header: {
                    Text(section.title)
                        .font(.headline)
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAppInfo, content: {
            NavigationView {
                AppInfoView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                viewModel.showingAppInfo = false
                            }
                        }
                    }
            }
            
        })
        .sheet(isPresented: $viewModel.showingInterfaceStyle) {
            InterfaceStyleView()
        }

    }
}

struct ActionRowView: View {
    let action: DebugAction
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(action.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    if let description = action.description, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
        }
    }
}

struct ActionsSectionHeaderView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ActionsView()
}
