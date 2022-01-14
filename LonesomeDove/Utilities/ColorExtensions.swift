//
//  ColorExtensions.swift
//  LonesomeDove
//  Created on 10/21/21.
//

import SwiftUI

extension Color {
    static let darkBackground = Color("default_background")
    static let defaultShadowColor = Color("default_shadow_color")
    static let defaultTextColor = Color("default_text_color")

    private static let funColors = [
        Color("fun_color_1"),
        Color("fun_color_2"),
        Color("fun_color_3"),
        Color("fun_color_4"),
        Color("fun_color_5"),
        Color("fun_color_6")
    ]

    static func funColor() -> Color {
        var seededGenerator = SeededNumberGenerator(seed: 1000)
        let index = Int.random(in: 0..<6, using: &seededGenerator)
        return Color.funColors[index]
    }

    static func funColor(for index: Int) -> Color {
        let colorIndex = index % funColors.count
        return Color.funColors[colorIndex]
    }
}
