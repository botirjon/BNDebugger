//
//  UserDefaultsView.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//

import SwiftUI

struct UserDefaultsView: View {
    @StateObject private var viewModel = UserDefaultsViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.userDefaultsEntries.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    userDefaultsList
                }
            }
            .navigationTitle("UserDefaults")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search keys or values")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: viewModel.refreshUserDefaults) {
                        Image(systemName: "arrow.clockwise")
                    }
                    
                    Button(action: {
                        viewModel.showingClearAlert = true
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
            .onAppear {
                viewModel.loadUserDefaults()
            }
            .alert("Clear UserDefaults", isPresented: $viewModel.showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    viewModel.clearAllUserDefaults()
                }
            } message: {
                Text("This will remove all UserDefaults entries. This action cannot be undone.")
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No UserDefaults Found")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("UserDefaults appears to be empty or contains only system entries.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var userDefaultsList: some View {
        List {
            ForEach(filteredEntries, id: \.key) { entry in
                UserDefaultsEntryView(entry: entry) {
                    viewModel.deleteEntry(key: entry.key)
                }
            }
        }
        .refreshable {
            viewModel.refreshUserDefaults()
        }
    }
    
    private var filteredEntries: [UserDefaultsEntry] {
        if searchText.isEmpty {
            return viewModel.userDefaultsEntries
        } else {
            return viewModel.userDefaultsEntries.filter { entry in
                entry.key.localizedCaseInsensitiveContains(searchText) ||
                entry.displayValue.localizedCaseInsensitiveContains(searchText) ||
                entry.type.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct UserDefaultsEntryView: View {
    let entry: UserDefaultsEntry
    let onDelete: () -> Void
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.key)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(entry.type)
                        .font(.system(size: 10))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if isExpanded || entry.displayValue.count <= 100 {
                Text(entry.displayValue)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(entry.displayValue.prefix(100)) + "...")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.secondary)
                    
                    Button("Show More") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded = true
                        }
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
                }
            }
            
            if isExpanded && entry.displayValue.count > 100 {
                Button("Show Less") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded = false
                    }
                }
                .font(.system(size: 12))
                .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}



#Preview {
    UserDefaultsView()
}
