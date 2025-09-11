//
//  NetworkRequestsView.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//

import SwiftUI

struct NetworkRequestsView: View {
    @StateObject private var viewModel = NetworkRequestsViewModel()
    @State private var showingClearAlert = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if #unavailable(iOS 15.0) {
                    SearchBar(text: $searchText, placeholder: "Search requests, URLs, or methods")
                        .padding(.horizontal)
                }
                
                if filteredRequests.isEmpty && !searchText.isEmpty {
                    emptySearchStateView
                } else if viewModel.networkRequests.isEmpty {
                    emptyStateView
                } else {
                    requestsList
                }
            }
            .navigationTitle("Network")
            .modifier(ConditionalSearchableModifier(text: $searchText, prompt: "Search requests, URLs, or methods"))
            .navigationBarItems(trailing: 
                HStack {
                    Button(action: viewModel.loadNetworkRequests) {
                        Image(systemName: "arrow.clockwise")
                    }
                    
                    Button(action: {
                        showingClearAlert = true
                    }) {
                        Image(systemName: "trash")
                    }
                }
            )
            .alert(isPresented: $showingClearAlert) {
                Alert(
                    title: Text("Clear Network Requests"),
                    message: Text("Are you sure you want to clear all network requests?"),
                    primaryButton: .destructive(Text("Clear")) {
                        viewModel.clearRequests()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private var requestsList: some View {
        Group {
            if #available(iOS 15.0, *) {
                List {
                    ForEach(filteredRequests, id: \.id) { request in
                        NavigationLink(destination: NetworkRequestDetailView(request: request)) {
                            NetworkRequestRowView(request: request)
                        }
                    }
                }
                .refreshable {
                    viewModel.loadNetworkRequests()
                }
            } else {
                List {
                    ForEach(filteredRequests, id: \.id) { request in
                        NavigationLink(destination: NetworkRequestDetailView(request: request)) {
                            NetworkRequestRowView(request: request)
                        }
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "network.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Network Requests")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Network requests will appear here as your app makes API calls.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptySearchStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Results Found")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("No network requests match your search criteria.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var filteredRequests: [NetworkRequest] {
        if searchText.isEmpty {
            return viewModel.networkRequests
        } else {
            return viewModel.networkRequests.filter { request in
                request.url.localizedCaseInsensitiveContains(searchText) ||
                request.method.localizedCaseInsensitiveContains(searchText) ||
                (request.response?.statusCode.description.contains(searchText) ?? false) ||
                statusText(for: request).localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func statusText(for request: NetworkRequest) -> String {
        switch request.status {
        case .pending:
            return "pending"
        case .completed:
            if let statusCode = request.response?.statusCode {
                return "\(statusCode) completed"
            } else {
                return "completed"
            }
        case .failed:
            return "failed"
        }
    }
}

#Preview {
    NetworkRequestsView()
}
