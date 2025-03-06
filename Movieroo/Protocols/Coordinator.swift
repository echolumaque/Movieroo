//
//  Coordinator.swift
//  Movieroo
//
//  Created by Echo Lumaque on 3/6/25.
//

import Foundation

protocol Coordinator: AnyObject {
    func start()
    var onFinished: (() -> Void)? { get set }
}
  
