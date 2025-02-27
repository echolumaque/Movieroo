//
//  Constants.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import Foundation

enum Configuration {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }
    
    enum NetworkCall: String {
        case baseUrl = "https://api.themoviedb.org/3"
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey:key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}

enum Environment {
    static let isForPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}

enum Section { case main }
