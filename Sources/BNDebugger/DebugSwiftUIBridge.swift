//
//  DebugSwiftUIBridge.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//

import SwiftUI
import UIKit

extension UIViewController {
    func presentSwiftUIDebugView() {
        let debugView = DebugView { [weak self] in
            self?.dismiss(animated: true)
        }
        
        let hostingController = UIHostingController(rootView: debugView)
        hostingController.modalPresentationStyle = .fullScreen
        
        present(hostingController, animated: true)
    }
}

struct DebugViewWrapper: UIViewControllerRepresentable {
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> UIHostingController<DebugView> {
        let debugView = DebugView(onDismiss: onDismiss)
        return UIHostingController(rootView: debugView)
    }
    
    func updateUIViewController(_ uiViewController: UIHostingController<DebugView>, context: Context) {
        
    }
}