//
//  FolderContentsView.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 13/09/25.
//

import SwiftUI

struct FolderContentsView: View {
    let resourceType: ResourceType
    let viewModel: ResourcesViewModel
    
    @State private var items: [FileItem] = []
    @State private var searchText = ""
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: FileItem?
    
    var filteredItems: [FileItem] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack {
            // Search bar for iOS 14 compatibility
            if #unavailable(iOS 15.0) {
                SearchBar(text: $searchText, placeholder: "Search files")
                    .padding(.horizontal)
            }
            
            List {
                if filteredItems.isEmpty && !searchText.isEmpty {
                    Text("No files found")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(filteredItems) { item in
                        if item.isDirectory {
                            DirectoryRowView(item: item)
                        } else {
                            NavigationLink(destination: FileDetailView(item: item, viewModel: viewModel)) {
                                FileRowView(item: item)
                            }
                            .contextMenu {
                                Button {
                                    itemToDelete = item
                                    showingDeleteAlert = true
                                } label: {
                                    Text("Delete").foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(resourceType.displayName)
        .modifier(ConditionalSearchableModifier(text: $searchText, prompt: "Search files"))
        .onAppear {
            loadItems()
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete File"),
                message: Text(itemToDelete != nil ? "Are you sure you want to delete '\(itemToDelete!.name)'? This action cannot be undone." : ""),
                primaryButton: .destructive(Text("Delete")) {
                    if let item = itemToDelete {
                        deleteFile(item)
                    }
                },
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
    }
    
    private func loadItems() {
        items = viewModel.getFolderContents(for: resourceType)
    }
    
    private func deleteFile(_ item: FileItem) {
        if viewModel.deleteFile(at: item.path) {
            loadItems() // Refresh the list
        }
    }
}

struct FileRowView: View {
    let item: FileItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName(for: item.name))
                .font(.title2)
                .foregroundColor(iconColor(for: item.name))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack {
                    if !item.displaySize.isEmpty {
                        Text(item.displaySize)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let modificationDate = item.modificationDate {
                        Text(DateFormatter.localizedString(from: modificationDate, dateStyle: .short, timeStyle: .none))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()

        }
        .padding(.vertical, 4)
    }
    
    private func iconName(for fileName: String) -> String {
        let fileExtension = (fileName as NSString).pathExtension.lowercased()
        
        switch fileExtension {
        case "txt", "rtf":
            return "doc.text"
        case "pdf":
            return "doc.richtext"
        case "jpg", "jpeg", "png", "gif", "bmp":
            return "photo"
        case "mp4", "mov", "avi":
            return "video"
        case "mp3", "wav", "aac":
            return "music.note"
        case "zip", "rar", "7z":
            return "archivebox"
        case "json":
            return "curlybraces"
        case "xml", "html":
            return "chevron.left.forwardslash.chevron.right"
        case "plist":
            return "list.bullet.rectangle"
        default:
            return "doc"
        }
    }
    
    private func iconColor(for fileName: String) -> Color {
        let fileExtension = (fileName as NSString).pathExtension.lowercased()
        
        switch fileExtension {
        case "txt", "rtf":
            return .blue
        case "pdf":
            return .red
        case "jpg", "jpeg", "png", "gif", "bmp":
            return .green
        case "mp4", "mov", "avi":
            return .purple
        case "mp3", "wav", "aac":
            return .pink
        case "zip", "rar", "7z":
            return .orange
        case "json", "xml", "html", "plist":
            return Color(hue: 0.5, saturation: 1.0, brightness: 1.0)
        default:
            return .gray
        }
    }
}

struct DirectoryRowView: View {
    let item: FileItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "folder.fill")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let modificationDate = item.modificationDate {
                    Text(DateFormatter.localizedString(from: modificationDate, dateStyle: .short, timeStyle: .none))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text("Folder")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(6)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let viewModel = ResourcesViewModel()
    FolderContentsView(resourceType: .tmpFolder, viewModel: viewModel)
}
