//
//  FileDetailView.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 13/09/25.
//

import SwiftUI

struct FileDetailView: View {
    let item: FileItem
    let viewModel: ResourcesViewModel
    
    @State private var fileContent: String = ""
    @State private var fileInfo: [String: String] = [:]
    @State private var isLoading = true
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // File Info Section
                FileInfoSection(fileInfo: fileInfo)
                
                // Content Section
                FileContentSection(content: fileContent, fileName: item.name)
            }
            .padding()
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: 
            Button("Delete") {
                showingDeleteAlert = true
            }
            .foregroundColor(.red)
        )
        .onAppear {
            loadFileData()
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete File"),
                message: Text("Are you sure you want to delete '\(item.name)'? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    deleteFile()
                },
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
    }
    
    private func loadFileData() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let content = viewModel.getFileContent(at: item.path) ?? "Unable to read file content"
            let info = viewModel.getFileInfo(at: item.path)
            
            DispatchQueue.main.async {
                self.fileContent = content
                self.fileInfo = info
                self.isLoading = false
            }
        }
    }
    
    private func deleteFile() {
        if viewModel.deleteFile(at: item.path) {
            // Navigate back after successful deletion
            // Note: In a real implementation, you might want to use a coordinator pattern
            // or pass a completion handler to handle navigation
        }
    }
}

struct FileInfoSection: View {
    let fileInfo: [String: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("File Information")
                    .font(.headline)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible(minimum: 80), alignment: .leading),
                GridItem(.flexible(minimum: 100), alignment: .leading)
            ], alignment: .leading, spacing: 8) {
                ForEach(Array(fileInfo.keys.sorted()), id: \.self) { key in
                    Text(key)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    if #available(iOS 15.0, *) {
                        Text(fileInfo[key] ?? "")
                            .font(.subheadline)
                            .textSelection(.enabled)
                    } else {
                        Text(fileInfo[key] ?? "")
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct FileContentSection: View {
    let content: String
    let fileName: String
    
    @State private var showingRawContent = false
    
    var isTextFile: Bool {
        let textExtensions = ["txt", "json", "xml", "plist", "log", "md", "html", "css", "js", "py", "swift", "m", "h"]
        let fileExtension = (fileName as NSString).pathExtension.lowercased()
        return textExtensions.contains(fileExtension) || content.count < 10000
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.green)
                Text("Content")
                    .font(.headline)
                Spacer()
                
                if isTextFile && content.count > 1000 {
                    Button(showingRawContent ? "Formatted" : "Raw") {
                        showingRawContent.toggle()
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(6)
                }
            }
            
            if isTextFile {
                ScrollView {
                    if #available(iOS 15.0, *) {
                        Text(content)
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    } else {
                        Text(content)
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                }
                .frame(minHeight: 200, maxHeight: 400)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title)
                        .foregroundColor(.orange)
                    
                    Text("Binary File")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("This file contains binary data that cannot be displayed as text.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    if content.count < 1000 {
                        Text("Hex representation (first 500 chars):")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top)
                        
                        if #available(iOS 15.0, *) {
                            Text(String(content.prefix(500)))
                                .font(.system(.caption, design: .monospaced))
                                .textSelection(.enabled)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(6)
                        } else {
                            Text(String(content.prefix(500)))
                                .font(.system(.caption, design: .monospaced))
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(6)
                        }
                    }
                }
                .padding()
                .frame(minHeight: 200)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    let viewModel = ResourcesViewModel()
    let item = FileItem(
        name: "example.txt",
        path: "/tmp/example.txt",
        isDirectory: false,
        size: 1024,
        modificationDate: Date()
    )
    FileDetailView(item: item, viewModel: viewModel)
}
