//
//  String+Extension.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import Foundation

extension String {
    var formatDateToLocale: String {
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX") // ensures consistent parsing
        inputFormatter.dateFormat = "yyyy-MM-dd"

        if let date = inputFormatter.date(from: self) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .long
            let userDateString = outputFormatter.string(from: date)
            
            return userDateString
        }
        
        return ""
    }
}
