//
//  Helper.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 29/07/25.
//

import Foundation

extension String {
    func firstMatch(of pattern: String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern)
        let nsrange = NSRange(self.startIndex..<self.endIndex, in: self)
        if let match = regex?.firstMatch(in: self, options: [], range: nsrange),
           let range = Range(match.range, in: self) {
            return String(self[range])
        }
        return nil
    }
}
