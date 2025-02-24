//
//  Int+Extension.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/25/25.
//

import Foundation

extension Int {
    var timeString: String {
        let hours = self / 60
        let minutes = self % 60
        return "\(hours)h \(minutes)m"
    }
}
