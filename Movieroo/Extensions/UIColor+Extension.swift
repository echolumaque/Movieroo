//
//  UIColor+Extension.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/25/25.
//

import UIKit

extension UIColor {
//    var hexString: String {
//        let components = cgColor.components
//        let r: CGFloat = components?[0] ?? 0.0
//        let g: CGFloat = components?[1] ?? 0.0
//        let b: CGFloat = components?[2] ?? 0.0
//        
//        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
//        print(hexString)
//        return hexString
//    }
 
    var hexString: String {
        // Get the color's components and color space model
        guard let components = cgColor.components,
              let model = cgColor.colorSpace?.model else {
            return "#00000000"
        }
        
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        
        switch model {
        case .monochrome:
            // For a monochrome color, components[0] is the white value and components[1] is alpha.
            r = components[0]
            g = components[0]
            b = components[0]
            a = components.count > 1 ? components[1] : 1.0
        case .rgb:
            // For an RGB color, components are ordered as red, green, blue, alpha.
            r = components[0]
            g = components[1]
            b = components[2]
            a = components.count > 3 ? components[3] : 1.0
        default:
            // Unsupported color space; return a default value.
            return "#00000000"
        }
        
        // Format each component to a two-digit hex value.
        return String(format: "#%02lX%02lX%02lX%02lX",
                      lroundf(Float(r * 255)),
                      lroundf(Float(g * 255)),
                      lroundf(Float(b * 255)),
                      lroundf(Float(a * 255)))
    }
}
