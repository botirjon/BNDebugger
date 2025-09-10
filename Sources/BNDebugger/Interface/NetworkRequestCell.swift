//
//  NetworkRequestCell.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 10/09/25.
//

import UIKit

class NetworkRequestCell: UITableViewCell {
    private let methodLabel = UILabel()
    private let urlLabel = UILabel()
    private let statusLabel = UILabel()
    private let timestampLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        methodLabel.font = UIFont.boldSystemFont(ofSize: 14)
        methodLabel.textColor = .systemBlue
        
        urlLabel.font = UIFont.systemFont(ofSize: 14)
        urlLabel.numberOfLines = 2
        
        statusLabel.font = UIFont.systemFont(ofSize: 12)
        statusLabel.textAlignment = .right
        
        timestampLabel.font = UIFont.systemFont(ofSize: 10)
        timestampLabel.textColor = .systemGray
        timestampLabel.textAlignment = .right
        
        let stackView = UIStackView(arrangedSubviews: [
            methodLabel,
            urlLabel,
            UIStackView(arrangedSubviews: [statusLabel, timestampLabel])
        ])
        stackView.axis = .vertical
        stackView.spacing = 4
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }
    
    func configure(with request: NetworkRequest) {
        methodLabel.text = request.method
        urlLabel.text = request.url
        
        // --- Status label ---
        switch request.status {
        case .pending:
            statusLabel.text = "⏳ Pending"
            statusLabel.textColor = .systemOrange
        case .completed:
            if let statusCode = request.response?.statusCode {
                statusLabel.text = "\(statusCode)"
                if (200..<300).contains(statusCode) {
                    statusLabel.textColor = .systemGreen
                } else if (400..<600).contains(statusCode) {
                    statusLabel.textColor = .systemRed
                } else {
                    statusLabel.textColor = .systemGray
                }
            } else {
                statusLabel.text = "Completed"
                statusLabel.textColor = .systemGray
            }
        case .failed:
            statusLabel.text = "❌ Failed"
            statusLabel.textColor = .systemRed
        }
        
        // --- Timestamp label ---
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        timestampLabel.text = formatter.string(from: request.timestamp)
    }
}
