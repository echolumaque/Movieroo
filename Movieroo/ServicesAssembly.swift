//
//  ServicesAssembly.swift
//  Movieroo
//
//  Created by Echo Lumaque on 3/11/25.
//

import Swinject

class ServicesAssembly: Assembly {
    func assemble(container: Container) {
        container.register(PersistenceManager.self) { _ in
            PersistenceManagerImpl()
        }.inObjectScope(.container)
        
        container.register(NetworkManager.self) { _ in
            NetworkManagerImpl()
        }.inObjectScope(.container)
    }
}
