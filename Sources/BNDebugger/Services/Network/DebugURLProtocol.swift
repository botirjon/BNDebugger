//
//  DebugURLProtocol.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 12/09/25.
//

import Foundation

public class DebugURLProtocol: URLProtocol, URLSessionDataDelegate {
    private static let requestProperty = "DebugURLProtocolHandled"
    private var session: URLSession?
    private var dataTask: URLSessionDataTask?
    private var requestStartTime: Date?
    private var networkRequest: NetworkRequest?
    private var responseData = Data()
    
    public override class func canInit(with request: URLRequest) -> Bool {
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
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    public override func startLoading() {
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
            NotificationCenter.default.post(name: .debugRequestDidStart, object: networkRequest)
        }
        
        // Create session and data task
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        dataTask = session?.dataTask(with: newRequest as URLRequest)
        dataTask?.resume()
    }
    
    public override func stopLoading() {
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
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        responseData.append(data)
        client?.urlProtocol(self, didLoad: data)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
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
            
            let update = NetworkRequestUpdate(
                id: networkRequest.id,
                response: networkResponse,
                status: .completed
            )
            
            NotificationCenter.default.post(name: .debugRequestDidUpdate, object: update)
            
        } else if error != nil {
            let update = NetworkRequestUpdate(
                id: networkRequest.id,
                response: nil,
                status: .failed
            )
            NotificationCenter.default.post(name: .debugRequestDidUpdate, object: update)
        }
    }
}
