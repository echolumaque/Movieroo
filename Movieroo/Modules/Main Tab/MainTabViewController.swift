//
//  MainTabViewController.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit

protocol MainTabView: AnyObject {
    var presenter: MainTabPresenter? { get set }
}

class MainTabViewController: UITabBarController, MainTabView {
    var presenter: (any MainTabPresenter)?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        tabBar.tintColor = .systemPurple
    }
}

extension MainTabViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}

#Preview {
    MainTabViewController()
}
