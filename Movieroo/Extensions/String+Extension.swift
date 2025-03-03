//
//  String+Extension.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit

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
    
    var formatISO8601DateToLocale: String {
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX") // ensures consistent parsing
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        if let date = inputFormatter.date(from: self) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .long
            outputFormatter.timeStyle = .long
            let userDateString = outputFormatter.string(from: date)
            
            return userDateString
        }
        
        return ""
    }
    
    func containsInsensitive(_ searchString: String) -> Bool {
        range(of: searchString, options: [.caseInsensitive, .diacriticInsensitive]) != nil
    }
    
    func htmlAttributedString(size: CGFloat, color: UIColor) -> NSAttributedString? {
        let htmlTemplate = """
        <!doctype html>
        <html>
          <head>
            <style>
              body {
                color: \(color.hexString);
                font-family: -apple-system;
                font-size: \(size)px;
              }
            </style>
          </head>
          <body>
            \(self)
          </body>
        </html>
        """

        guard let data = htmlTemplate.data(using: .utf8) else {
            return nil
        }

        guard let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
            ) else {
            return nil
        }

        return attributedString
    }
}
