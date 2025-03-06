//
//  BindableViewController.swift
//  Movieroo
//
//  Created by Echo Lumaque on 3/6/25.
//

import UIKit
import Combine

class BindableViewController: UIViewController {
    var subscriptions = Set<AnyCancellable>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        subscriptions.removeAll()
    }
    
    func bindViewModel() { }
    
    func bind<P: Publisher>(_ publisher: P, action: @escaping (P.Output) -> Void) where P.Failure == Never {
        publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: action)
            .store(in: &subscriptions)
    }
}
