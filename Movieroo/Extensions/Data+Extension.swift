//
//  Data+Extension.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import Foundation

extension Data {
    func decode<T: Decodable>(to type: T.Type,
                              keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy? = nil,
                              dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil) throws -> T {
        let decoder = JSONDecoder()
        if let keyDecodingStrategy { decoder.keyDecodingStrategy = keyDecodingStrategy }
        if let dateDecodingStrategy { decoder.dateDecodingStrategy = dateDecodingStrategy }
        
        return try decoder.decode(type, from: self)
    }
}
