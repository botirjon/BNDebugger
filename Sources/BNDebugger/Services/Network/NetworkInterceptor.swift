//
//  NetworkInterceptor.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 10/09/25.
//

import Foundation
import UIKit

// MARK: - Network Interceptor
class NetworkInterceptor: NSObject {
    
    private var requests: [NetworkRequest] = []
    private let requestQueue = DispatchQueue(label: "com.debugtool.network", attributes: .concurrent)
    private var requestStartObserver: NSObjectProtocol?
    private var requestUpdateObserver: NSObjectProtocol?
    
    var onAdd: ((NetworkRequest) -> Void)?
    var onClear: (() -> Void)?
    
    override init() {
        super.init()
        requestStartObserver = NotificationCenter.default.addObserver(forName: .debugRequestDidStart, object: nil, queue: .main) { [weak self] notification in
            self?.requestStarted(notification)
        }
        requestUpdateObserver = NotificationCenter.default.addObserver(forName: .debugRequestDidUpdate, object: nil, queue: .main) { [weak self] notification in
            self?.requestUpdated(notification)
        }
    }
    
    deinit {
        if let observer = requestStartObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = requestUpdateObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func requestStarted(_ notification: Notification) {
        guard let request = notification.object as? NetworkRequest else { return }
        addRequest(request)
    }
    
    private func requestUpdated(_ notification: Notification) {
        guard let update = notification.object as? NetworkRequestUpdate else { return }
        updateRequest(id: update.id, response: update.response, status: update.status)
    }
    
    private func addRequest(_ request: NetworkRequest) {
        requestQueue.async(flags: .barrier) {
            self.requests.append(request)
        }
        
        onAdd?(request)
    }
    
    private func updateRequest(id: UUID, response: NetworkResponse?, status: NetworkRequest.RequestStatus) {
        requestQueue.async(flags: .barrier) {
            if let index = self.requests.firstIndex(where: { $0.id == id }) {
                self.requests[index].response = response
                self.requests[index].status = status
            }
        }
    }
}

// MARK: - Conformance to NetworkIntercepting
extension NetworkInterceptor: NetworkIntercepting {
    func startIntercepting() {
        URLProtocol.registerClass(DebugURLProtocol.self)
    }
    
    func stopIntercepting() {
        URLProtocol.unregisterClass(DebugURLProtocol.self)
    }
}

// MARK: - Conformance to NetworkRequestsStoring
extension NetworkInterceptor: NetworkRequestsStoring {
    func getAllRequests() -> [NetworkRequest] {
        return requestQueue.sync {
            return Array(requests.reversed()) // Show newest first
        }
    }
    
    func clearRequests() {
        requestQueue.async(flags: .barrier) {
            self.requests.removeAll()
        }
        
        onClear?()
    }
}



