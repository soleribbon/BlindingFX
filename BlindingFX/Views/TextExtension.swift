//
//  Text.swift
//  BlindingFX
//
//  Created by Ravi Heyne on 05/04/24.
//

import Foundation
import SwiftUI

//Go-to styling for different elements
extension Text {
    // Style for slider label
    func sliderLabel() -> Text {
        return self
            .bold()
            .foregroundStyle(.primary)
    }

    // Style for reset label
    func resetLabel() -> Text {
        return self
            .foregroundStyle(.red)
            .underline()
            .bold()
            .font(.body)
    }

    // Style for slider unit label
    func sliderUnitLabel() -> Text {
        return self
            .font(.title3)
            .foregroundStyle(.primary)
            .bold()


    }

    // Default style for labels
    func defaultLabel() -> Text {
        return self
            .font(.caption)
            .foregroundStyle(.gray)
    }
}

// ViewModifier to apply a consistent icon style
struct IconStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .foregroundStyle(.primary)
    }
}

// Icon style
extension Image {
    func iconStyle() -> some View {
        self.modifier(IconStyle())
    }
}
//For VStack Gradient
extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
