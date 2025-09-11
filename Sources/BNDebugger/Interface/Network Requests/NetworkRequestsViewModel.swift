//
//  NetworkRequestsViewModel.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//

import Foundation
import Combine

@MainActor
class NetworkRequestsViewModel: ObservableObject {
    @Published var networkRequests: [NetworkRequest] = []
    
    private var timer: Timer?
    
    init() {
        loadNetworkRequests()
        startAutoRefresh()
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    func loadNetworkRequests() {
        networkRequests = NetworkInterceptor.shared.getAllRequests()
    }
    
    func clearRequests() {
        NetworkInterceptor.shared.clearRequests()
        networkRequests.removeAll()
    }
    
    private func startAutoRefresh() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.loadNetworkRequests()
            }
        }
    }
    
    private func stopAutoRefresh() {
        timer?.invalidate()
        timer = nil
    }
}
