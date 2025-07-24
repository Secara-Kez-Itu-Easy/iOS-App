//
//  Hexagon.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 24/07/25.
//

import SwiftUI

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height

        let points: [CGPoint] = [
            CGPoint(x: 0.5 * width, y: -20),
            CGPoint(x: width, y: 0.215 * height),
            CGPoint(x: width, y: 0.875 * height),
            CGPoint(x: 0.5 * width, y: height + 20),
            CGPoint(x: 0, y: 0.875 * height),
            CGPoint(x: 0, y: 0.215 * height),
        ]

        var path = Path()
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()

        return path
    }
}
