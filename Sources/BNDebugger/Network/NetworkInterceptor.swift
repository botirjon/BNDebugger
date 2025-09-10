//
//  NetworkInterceptor.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 10/09/25.
//

import Foundation
import UIKit

// MARK: - Network Request Model
struct NetworkRequest {
    let id = UUID()
    let url: String
    let method: String
    let headers: [String: String]
    let body: Data?
    let timestamp: Date
    var response: NetworkResponse?
    var status: RequestStatus = .pending
    
    enum RequestStatus {
        case pending
        case completed
        case failed
    }
}

struct NetworkResponse {
    let statusCode: Int
    let headers: [String: String]
    let body: Data?
    let responseTime: TimeInterval
}

// MARK: - Network Interceptor
class NetworkInterceptor: NSObject {
    static let shared = NetworkInterceptor()
    
    private var requests: [NetworkRequest] = []
    private let requestQueue = DispatchQueue(label: "com.debugtool.network", attributes: .concurrent)
    
    private override init() {
        super.init()
    }
    
    func startIntercepting() {
        URLProtocol.registerClass(DebugURLProtocol.self)
    }
    
    func stopIntercepting() {
        URLProtocol.unregisterClass(DebugURLProtocol.self)
    }
    
    func addRequest(_ request: NetworkRequest) {
        requestQueue.async(flags: .barrier) {
            self.requests.append(request)
        }
        
        // Trigger rocket animation on debug button
        DebugManager.shared.animateNetworkRequest()
    }
    
    func updateRequest(id: UUID, response: NetworkResponse?, status: NetworkRequest.RequestStatus) {
        requestQueue.async(flags: .barrier) {
            if let index = self.requests.firstIndex(where: { $0.id == id }) {
                self.requests[index].response = response
                self.requests[index].status = status
            }
        }
    }
    
    func getAllRequests() -> [NetworkRequest] {
        return requestQueue.sync {
            return Array(requests.reversed()) // Show newest first
        }
    }
    
    func clearRequests() {
        requestQueue.async(flags: .barrier) {
            self.requests.removeAll()
        }
        
        // Update debug button count
        DebugManager.shared.updateRequestCount()
    }
}

// MARK: - Custom URL Protocol for Interception
class DebugURLProtocol: URLProtocol, URLSessionDataDelegate {
    private static let requestProperty = "DebugURLProtocolHandled"
    private var session: URLSession?
    private var dataTask: URLSessionDataTask?
    private var requestStartTime: Date?
    private var networkRequest: NetworkRequest?
    private var responseData = Data()
    
    override class func canInit(with request: URLRequest) -> Bool {
        // Avoid handling our own requests
        if URLProtocol.property(forKey: requestProperty, in: request) != nil {
            return false
        }
        
        // Only handle HTTP/HTTPS requests
        guard let url = request.url,
              let scheme = url.scheme,
              scheme == "http" || scheme == "https" else {
            return false
        }
        
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let newRequest = createMutableRequest() else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        
        requestStartTime = Date()
        
        // Create network request record
        let headers = newRequest.allHTTPHeaderFields ?? [:]
        networkRequest = NetworkRequest(
            url: newRequest.url?.absoluteString ?? "",
            method: newRequest.httpMethod,
            headers: headers,
            body: newRequest.httpBody,
            timestamp: requestStartTime!
        )
        
        if let networkRequest = networkRequest {
            NetworkInterceptor.shared.addRequest(networkRequest)
        }
        
        // Create session and data task
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        dataTask = session?.dataTask(with: newRequest as URLRequest)
        dataTask?.resume()
    }
    
    override func stopLoading() {
        dataTask?.cancel()
        session?.finishTasksAndInvalidate()
    }
    
    private func createMutableRequest() -> NSMutableURLRequest? {
        let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest
        if let mutableRequest {
            URLProtocol.setProperty(true, forKey: DebugURLProtocol.requestProperty, in: mutableRequest)
        }
        return mutableRequest
    }

    
    // MARK: - URL Session Delegate
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        responseData.append(data)
        client?.urlProtocol(self, didLoad: data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
            updateNetworkRequest(with: nil, error: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
            updateNetworkRequest(with: task.response, error: nil)
        }
    }
    
    private func updateNetworkRequest(with response: URLResponse?, error: Error?) {
        guard let networkRequest = networkRequest,
              let startTime = requestStartTime else { return }
        
        let responseTime = Date().timeIntervalSince(startTime)
        
        if let httpResponse = response as? HTTPURLResponse {
            let networkResponse = NetworkResponse(
                statusCode: httpResponse.statusCode,
                headers: httpResponse.allHeaderFields as? [String: String] ?? [:],
                body: responseData.isEmpty ? nil : responseData,
                responseTime: responseTime
            )
            
            NetworkInterceptor.shared.updateRequest(
                id: networkRequest.id,
                response: networkResponse,
                status: .completed
            )
        } else if error != nil {
            NetworkInterceptor.shared.updateRequest(
                id: networkRequest.id,
                response: nil,
                status: .failed
            )
        }
    }
}
