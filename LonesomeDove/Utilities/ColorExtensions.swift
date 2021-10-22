//
//  ColorExtensions.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/21/21.
//

import SwiftUI

extension Color {
    static let darkBackground = Color("dark_background")
    
    private static let funColors = [
        Color("fun_color_1"),
        Color("fun_color_2"),
        Color("fun_color_3"),
        Color("fun_color_4"),
        Color("fun_color_5"),
        Color("fun_color_6"),
    ]
    
    static func funColor() -> Color {
        let index = Int.random(in: 0..<6)
        return Color.funColors[index]
    }
}
