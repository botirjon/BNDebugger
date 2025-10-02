//
//  NetworkRequestsViewController.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 18/09/25.
//

import UIKit
import SwiftUI

class NetworkRequestsViewController: UIViewController {
    
    let viewModel: NetworkRequestsViewModel
    
    init(viewModel: NetworkRequestsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var child = UIHostingController(rootView: NetworkRequestsView(viewModel: viewModel))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(child)
        view.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Network"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: .init(systemName: "trash"), style: .plain, target: self, action: #selector(clear)),
            UIBarButtonItem(image: .init(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(refresh))
        ]
    }
    
    @objc private func refresh() {
        viewModel.loadNetworkRequests()
    }
    
    @objc private func clear() {
        let alert = UIAlertController(
            title: "Clear Network Requests",
            message: "Are you sure you want to clear all network requests?",
            preferredStyle: .alert)
        
        alert.addAction(.init(title: "Clear", style: .destructive, handler: { [weak self] _ in
            self?.viewModel.clearRequests()
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
