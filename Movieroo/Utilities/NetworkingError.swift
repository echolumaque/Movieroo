//
//  NetworkingError.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import Foundation

enum NetworkingError: Error {
    case encodingFailed(innerError: EncodingError)
    case decodingFailed(innerError: DecodingError)
    case invalidStatusCode(statusCode: Int)
    case requestFailed(innerError: URLError)
    case otherError(innerError: Error)
    case otherError(message: String)
}
