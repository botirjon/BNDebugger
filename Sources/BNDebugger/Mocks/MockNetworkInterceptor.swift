//
//  MockNetworkInterceptor.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 12/09/25.
//

import SwiftUI

final class MockNetworkInterceptor: NetworkIntercepting, NetworkRequestsStoring {
    var timer: Timer?
    private var requests: [NetworkRequest] = []
    
    init() {
        startIntercepting()
    }
    
    func startIntercepting() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                let newRequest = NetworkRequest(
                    url: "https://mock-url.com",
                    method: "GET",
                    headers: ["Content-Type":"application/json"],
                    body: nil,
                    timestamp: Date(),
                    response: .init(
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"],
                        body: "{\"success\":true}".data(using: .utf8, allowLossyConversion: false),
                        responseTime: 2
                    )
                )
                self?.requests.append(newRequest)
            }
        }
    }
    
    func stopIntercepting() {
        timer?.invalidate()
        timer = nil
    }
    
    func getAllRequests() -> [NetworkRequest] {
        requests
    }
    
    func clearRequests() {
        requests = []
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}
