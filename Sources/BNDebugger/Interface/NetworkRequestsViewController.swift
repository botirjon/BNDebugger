//
//  NetworkRequestsViewController.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 10/09/25.
//

import UIKit

// MARK: - Network Requests View Controller
class NetworkRequestsViewController: UIViewController {
    private let tableView = UITableView()
    private var networkRequests: [NetworkRequest] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        loadNetworkRequests()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NetworkRequestCell.self, forCellReuseIdentifier: "NetworkRequestCell")
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(clearRequestsTapped)
        )
    }
    
    @objc private func clearRequestsTapped() {
        let alert = UIAlertController(
            title: "Clear Network Requests",
            message: "Are you sure you want to clear all network requests?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            NetworkInterceptor.shared.clearRequests()
            self.networkRequests.removeAll()
            self.tableView.reloadData()
        })
        
        present(alert, animated: true)
    }
    
    private func loadNetworkRequests() {
        networkRequests = NetworkInterceptor.shared.getAllRequests()
        tableView.reloadData()
        
        // Refresh every 2 seconds
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.networkRequests = NetworkInterceptor.shared.getAllRequests()
                self?.tableView.reloadData()
            }
        }
    }
}

// MARK: - Network Requests Table View
extension NetworkRequestsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networkRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkRequestCell", for: indexPath) as! NetworkRequestCell
        let request = networkRequests[indexPath.row]
        cell.configure(with: request)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let request = networkRequests[indexPath.row]
        let detailVC = NetworkRequestDetailViewController(request: request)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
