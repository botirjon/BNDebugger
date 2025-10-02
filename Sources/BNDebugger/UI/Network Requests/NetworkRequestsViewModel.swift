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
    
    weak var networkInterceptor: NetworkIntercepting?
    weak var networkRequestsStore: NetworkRequestsStoring?
    
    init(networkInterceptor: NetworkIntercepting, networkRequestsStore: NetworkRequestsStoring?) {
        self.networkInterceptor = networkInterceptor
        self.networkRequestsStore = networkRequestsStore
        loadNetworkRequests()
        startAutoRefresh()
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    func loadNetworkRequests() {
        networkRequests = networkRequestsStore?.getAllRequests() ?? []
    }
    
    func clearRequests() {
        networkRequestsStore?.clearRequests()
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
