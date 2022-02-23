//
//  ColorExtensions.swift
//  LonesomeDove
//  Created on 10/21/21.
//

import UIKit
import SwiftUI

enum ColorNames: String {
    case default_background
    case default_shadow_color
    case default_text_color
    case fun_color_4
    case fun_color_1
    case fun_color_2
    case fun_color_3
    case fun_color_5
    case fun_color_6
}

extension Color {
    static let darkBackground = Color(ColorNames.default_background.rawValue)
    static let defaultShadowColor = Color(ColorNames.default_shadow_color.rawValue)
    static let defaultTextColor = Color(ColorNames.default_text_color.rawValue)
    static let badgeBackgroundColor = Color(ColorNames.fun_color_4.rawValue)

    private static let funColors = [
        Color(ColorNames.fun_color_1.rawValue),
        Color(ColorNames.fun_color_2.rawValue),
        Color(ColorNames.fun_color_3.rawValue),
        Color(ColorNames.fun_color_5.rawValue),
        Color(ColorNames.fun_color_6.rawValue)
    ]

    static func funColor(for color: Color) -> Color {
        switch color {
            case .green:
                return Color(ColorNames.fun_color_6.rawValue)
            case .blue:
                return Color(ColorNames.fun_color_5.rawValue)
            case .orange:
                return Color(ColorNames.fun_color_4.rawValue)
            case .red:
                return Color(ColorNames.fun_color_3.rawValue)
            case .yellow:
                return Color(ColorNames.fun_color_2.rawValue)
            case .purple:
                return Color(ColorNames.fun_color_1.rawValue)
            default:
                return color
        }
    }

    static func funColor() -> Color {
        var seededGenerator = SeededNumberGenerator(seed: 1000)
        let index = Int.random(in: 0..<6, using: &seededGenerator)
        return Color.funColors[index]
    }

    static func funColor(for index: Int) -> Color {
        let colorIndex = index % funColors.count
        return Color.funColors[colorIndex]
    }

    static func funColor(for duration: TimeInterval) -> Color {
        let index = Int(round(duration)) % funColors.count
        return Color.funColors[index]
    }
}

extension UIColor {

    static let darkBackground = UIColor(named: ColorNames.default_background.rawValue)
    static let defaultShadowColor = UIColor(named: ColorNames.default_shadow_color.rawValue)
    static let defaultTextColor = UIColor(named: ColorNames.default_text_color.rawValue)
    static let badgeBackgroundColor = UIColor(named: ColorNames.fun_color_4.rawValue)
}
