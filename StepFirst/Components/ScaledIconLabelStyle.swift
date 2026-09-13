//
//  ScaledIconLabelStyle.swift
//  StepFirst
//

import SwiftUI

struct ScaledIconLabelStyle: LabelStyle {
    var scale: CGFloat = 1.3
    var titleScale: CGFloat = 1.0
    var spacing: CGFloat = 12

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
                .scaleEffect(scale)
                .frame(width: 28 * scale, height: 28 * scale)
            configuration.title
                .scaleEffect(titleScale, anchor: .leading)
        }
    }
}

extension LabelStyle where Self == ScaledIconLabelStyle {
    static var scaledIcon: ScaledIconLabelStyle {
        ScaledIconLabelStyle()
    }

    static func scaledIcon(scale: CGFloat = 1.3, titleScale: CGFloat = 1.0, spacing: CGFloat = 12) -> ScaledIconLabelStyle {
        ScaledIconLabelStyle(scale: scale, titleScale: titleScale, spacing: spacing)
    }
}
