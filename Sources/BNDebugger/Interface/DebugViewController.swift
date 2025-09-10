//
//  DebugViewController.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 10/09/25.
//

import UIKit

// MARK: - Debug Interface View Controller
class DebugViewController: UITabBarController {
    var onDismiss: (() -> Void)?
    
    private lazy var networkViewController = NetworkRequestsViewController()
    private lazy var actionsViewController = ActionsViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTabBar()
        setupNavigationBar(selectedTabIndex: selectedIndex)
    }
    
    private func setupUI() {
        title = "Debug Console"
        view.backgroundColor = .systemBackground
        
        // Navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissTapped)
        )
    }
    
    private func setupTabBar() {
        // Setup network tab
        networkViewController.title = "Network"
        networkViewController.tabBarItem = UITabBarItem(
            title: "Network",
            image: UIImage(systemName: "network"),
            tag: 0
        )
        
        // Setup actions tab
        actionsViewController.title = "Actions"
        actionsViewController.tabBarItem = UITabBarItem(
            title: "Actions",
            image: UIImage(systemName: "gearshape"),
            tag: 1
        )
        
        // Set view controllers
        viewControllers = [networkViewController, actionsViewController]
    }
    
    @objc private func dismissTapped() {
        onDismiss?()
    }
    
    private func setupNavigationBar(selectedTabIndex index: Int) {
        if index == 0 {
            navigationItem.rightBarButtonItem = networkViewController.navigationItem.rightBarButtonItem
        } else {
            navigationItem.rightBarButtonItem = actionsViewController.navigationItem.rightBarButtonItem
        }
    }
}

extension DebugViewController: UITabBarControllerDelegate {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        setupNavigationBar(selectedTabIndex: item.tag)
    }
}
