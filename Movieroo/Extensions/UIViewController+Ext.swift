//
//  UIViewController+Ext.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit
import SafariServices

fileprivate var containerView: UIView!

extension UIViewController {
    func showLoadingView() {
        containerView = UIView(frame: view.bounds)
        view.addSubview(containerView)
        containerView.backgroundColor = .systemBackground
        containerView.alpha = 0
        
        // Starts the animation
        UIView.animate(withDuration: 0.25) { containerView.alpha = 0.8 }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        containerView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    func dismissLoadingView() {
//        guard containerView != nil else { return }
        DispatchQueue.main.async {
            containerView?.removeFromSuperview()
            containerView = nil
        }
    }
    
    func presentSafariVC(with url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = .systemPurple
        present(safariVC, animated: true)
    }
    
    @objc func dismissVC() {
        dismiss(animated: true)
    }
    
//    func showEmptyStateView(with message: String, in view: UIView) {
//        let emptyStateView = GFEmptyStateView(message: message)
//        emptyStateView.frame = view.bounds
//        view.addSubview(emptyStateView)
//    }
}
