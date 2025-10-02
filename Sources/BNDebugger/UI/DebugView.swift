//
//  DebugView.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//

import SwiftUI

struct DebugView: View {
    @ObservedObject private var viewModel: DebugViewModel
    let onDismiss: (() -> Void)?
    
    init(viewModel: DebugViewModel, onDismiss: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        NavigationView {
            TabView {
                NetworkRequestsView(viewModel: viewModel.networkRequestsViewModel)
                    .tabItem {
                        Image(systemName: "network")
                        Text("Network")
                    }
                    .tag(0)
                
                PerformanceView(viewModel: viewModel.performanceViewModel)
                    .tabItem {
                        Image(systemName: "speedometer")
                        Text("Performance")
                    }
                    .tag(1)
                
                ResourcesView(viewModel: viewModel.resourcesViewModel)
                    .tabItem {
                        Image(systemName: "folder.fill")
                        Text("Resources")
                    }
                    .tag(2)
                
                ActionsView()
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("Actions")
                    }
                    .tag(3)
            }
            .navigationTitle("Debug Console")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: 
                Button("Close") {
                    onDismiss?()
                }
            )
        }
    }
}

#Preview {
    let interceptor = MockNetworkInterceptor()
    let performanceMonitor = PerformanceMonitor()
    let viewModel = DebugViewModel(networkInterceptor: interceptor, networkRequestsStore: interceptor, performanceMonitor: performanceMonitor)
    DebugView(viewModel: viewModel, onDismiss: nil)
}
