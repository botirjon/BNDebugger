//
//  DebugView.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//

import SwiftUI

struct DebugView: View {
    let onDismiss: (() -> Void)?
    
    init(onDismiss: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        NavigationView {
            TabView {
                NetworkRequestsView()
                    .tabItem {
                        Image(systemName: "network")
                        Text("Network")
                    }
                    .tag(0)
                
                ActionsView()
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("Actions")
                    }
                    .tag(1)
            }
            .navigationTitle("Debug Console")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        onDismiss?()
                    }
                }
            }
        }
    }
}

#Preview {
    DebugView()
}