//
//  DebugManager.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 10/09/25.
//

import UIKit
import SwiftUI
import Foundation

public enum DebugLanguage {
    case uzbek
    case english
    case russian
}

public struct DebugInterfaceConfig {
    public var language: DebugLanguage = .uzbek
    public var userInterfaceStyle: UIUserInterfaceStyle?
    
    public init(language: DebugLanguage = .english, userInterfaceStyle: UIUserInterfaceStyle? = nil) {
        self.language = language
        self.userInterfaceStyle = userInterfaceStyle
    }
}

public class DebugManager: NSObject {
    public static let shared = DebugManager()
    
    private var isActive = false
    private var floatingButton: FloatingDebugButton?
    private var debugWindow: UIWindow?
    private var networkInterceptor: NetworkInterceptor?
    private var preferredLanguage: DebugLanguage = .english
    
    public var customActions: [CustomDebugAction] = []
    
    private var preferredUserInterfaceStyle: UIUserInterfaceStyle {
        getSavedUserInterfaceStyle() ?? .light
    }
    
    var currentUserInterfaceStyle: UIUserInterfaceStyle {
        debugWindow?.overrideUserInterfaceStyle ?? .light
    }
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public API
    public func startDebugging(with config: DebugInterfaceConfig = .init()) {
        guard !isActive else { return }
        isActive = true
        self.saveUserInterfaceStyle(config.userInterfaceStyle ?? .light)
        self.preferredLanguage = config.language
        
        setupFloatingButton()
        setupNetworkInterceptor()
        updateRequestCount() // Initialize count display
    }
    
    public func stopDebugging() {
        guard isActive else { return }
        isActive = false
        
        removeFloatingButton()
        networkInterceptor = nil
    }
    
    func animateNetworkRequest() {
        guard isActive else { return }
        DispatchQueue.main.async {
            self.floatingButton?.animateRocket()
            self.updateRequestCount()
        }
    }
    
    func updateRequestCount() {
        guard isActive else { return }
        let count = NetworkInterceptor.shared.getAllRequests().count
        DispatchQueue.main.async {
            self.floatingButton?.updateCount(count)
        }
    }
    
    // MARK: - Private Setup Methods
    private func setupFloatingButton() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else { return }
        
        floatingButton = FloatingDebugButton { [weak self] in
            self?.showDebugInterface()
        }
        
        floatingButton?.show(in: windowScene)
    }
    
    private func removeFloatingButton() {
        floatingButton?.hide()
        floatingButton = nil
    }
    
    private func setupNetworkInterceptor() {
        networkInterceptor = NetworkInterceptor.shared
        networkInterceptor?.startIntercepting()
    }
    
    private func showDebugInterface() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else { return }
        
        let debugView = DebugView { [weak self] in
            self?.debugWindow?.isHidden = true
            self?.debugWindow = nil
        }
        
        let hostingController = UIHostingController(rootView: debugView)
        
        debugWindow = UIWindow(windowScene: windowScene)
        debugWindow?.rootViewController = hostingController
        debugWindow?.windowLevel = UIWindow.Level.alert + 1
        debugWindow?.makeKeyAndVisible()
        debugWindow?.overrideUserInterfaceStyle = preferredUserInterfaceStyle
    }
    
    func updateUserInterfaceStyle(_ style: UIUserInterfaceStyle) {
        saveUserInterfaceStyle(style)
        debugWindow?.overrideUserInterfaceStyle = preferredUserInterfaceStyle
    }
    
    private func saveUserInterfaceStyle(_ style: UIUserInterfaceStyle) {
        UserDefaults.standard.set(style.rawValue, forKey: "DebugInterfaceStyle")
        UserDefaults.standard.synchronize()
    }
    
    private func getSavedUserInterfaceStyle() -> UIUserInterfaceStyle? {
        let savedStyleRawValue = UserDefaults.standard.integer(forKey: "DebugInterfaceStyle")
        let savedStyle = UIUserInterfaceStyle(rawValue: savedStyleRawValue)
        return savedStyle
    }
}

// MARK: - PassThrough Window
private class PassThroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        // If the hit view is the window itself (background), return nil to pass through
        if hitView == self || hitView == rootViewController?.view {
            return nil
        }
        
        return hitView
    }
}

// MARK: - Floating Debug Button
private class FloatingDebugButton: UIView {
    private let button = UIButton(type: .system)
    private let countLabel = UILabel()
    private let onTap: () -> Void
    private var embeddedWindow: PassThroughWindow?
    
    init(onTap: @escaping () -> Void) {
        self.onTap = onTap
        super.init(frame: CGRect(x: 20, y: 100, width: 60, height: 60))
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        button.setTitle("🐛", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        // Setup count label
        countLabel.font = UIFont.boldSystemFont(ofSize: 10)
        countLabel.textColor = .white
        countLabel.backgroundColor = UIColor.systemRed
        countLabel.textAlignment = .center
        countLabel.layer.cornerRadius = 8
        countLabel.clipsToBounds = true
        countLabel.text = "0"
        countLabel.isHidden = true // Initially hidden
        
        addSubview(button)
        addSubview(countLabel)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Position count label at top-right corner
            countLabel.topAnchor.constraint(equalTo: topAnchor, constant: -4),
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 4),
            countLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 16),
            countLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        // Make it draggable
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }
    
    @objc private func buttonTapped() {
        onTap()
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let window = window else { return }
        
        let translation = gesture.translation(in: window)
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        gesture.setTranslation(.zero, in: window)
        
        if gesture.state == .ended {
            // Snap to edges
            let screenBounds = window.bounds
            let newX = center.x < screenBounds.midX ? 30 : screenBounds.width - 30
            
            UIView.animate(withDuration: 0.3) {
                self.center.x = newX
            }
        }
    }
    
    func show(in windowScene: UIWindowScene) {
        embeddedWindow = PassThroughWindow(windowScene: windowScene)
        embeddedWindow?.windowLevel = UIWindow.Level.statusBar + 1
        embeddedWindow?.backgroundColor = UIColor.clear
        embeddedWindow?.rootViewController = UIViewController()
        embeddedWindow?.isHidden = false
        
        embeddedWindow?.addSubview(self)
    }
    
    func hide() {
        removeFromSuperview()
        embeddedWindow?.isHidden = true
        embeddedWindow = nil
    }
    
    func updateCount(_ count: Int) {
        let displayText = count > 99 ? "99+" : "\(count)"
        countLabel.text = displayText
        countLabel.isHidden = count == 0
    }
    
    func animateRocket() {
        guard let window = embeddedWindow else { return }
        
        // Create rocket emoji label
        let rocket = UILabel()
        rocket.text = "🚀"
        rocket.font = UIFont.systemFont(ofSize: 18)
        rocket.textAlignment = .center
        rocket.sizeToFit()
        
        // Position rocket at the center of the debug button
        let buttonCenterInWindow = convert(CGPoint(x: bounds.midX, y: bounds.midY), to: window)
        rocket.center = buttonCenterInWindow
        
        window.addSubview(rocket)
        
        // Animate rocket upward with fading opacity and slight scale
        UIView.animate(withDuration: 1.2, delay: 0, options: [.curveEaseOut], animations: {
            // Move rocket upward (80 points)
            rocket.transform = CGAffineTransform(translationX: 0, y: -80).scaledBy(x: 0.5, y: 0.5)
            // Fade out gradually
            rocket.alpha = 0
        }, completion: { _ in
            rocket.removeFromSuperview()
        })
    }
}
