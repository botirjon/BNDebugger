//
//  DebugViewModel.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 12/09/25.
//

import SwiftUI

@MainActor
final class DebugViewModel: ObservableObject {
    let networkRequestsViewModel: NetworkRequestsViewModel
    let performanceViewModel: PerformanceViewModel
    let resourcesViewModel: ResourcesViewModel
    
    init(networkInterceptor: NetworkIntercepting, networkRequestsStore: NetworkRequestsStoring, performanceMonitor: PerformanceMonitoring) {
        networkRequestsViewModel = .init(networkInterceptor: networkInterceptor, networkRequestsStore: networkRequestsStore)
        performanceViewModel = .init(performanceMonitor: performanceMonitor)
        resourcesViewModel = .init()
    }
}
