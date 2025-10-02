//
//  ResourcesView.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 13/09/25.
//

import SwiftUI

struct ResourcesView: View {
    @ObservedObject private var viewModel: ResourcesViewModel
    
    init(viewModel: ResourcesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List {
            ForEach(viewModel.resources) { resource in
                NavigationLink(destination: destinationView(for: resource)) {
                    ResourceRowView(resource: resource)
                }
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for resource: AppResource) -> some View {
        switch resource.type {
        case .tmpFolder, .documentsFolder:
            FolderContentsView(
                resourceType: resource.type,
                viewModel: viewModel
            )
        case .userDefaults:
            UserDefaultsView()
        }
    }
}

struct ResourceRowView: View {
    let resource: AppResource
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: resource.iconName)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(resource.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(resource.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let viewModel = ResourcesViewModel()
    ResourcesView(viewModel: viewModel)
}
