//
//  Layout+App.swift
//  StepFirst
//

import SwiftUI

enum AppLayout {
    /// Keeps content readable in wide windows (e.g. iPhone apps resized on iPad).
    static let readableWidth: CGFloat = 560
}

extension View {
    /// Caps the content width and centers it in wider windows.
    func readableWidth() -> some View {
        frame(maxWidth: AppLayout.readableWidth)
            .frame(maxWidth: .infinity)
    }
}

extension Sequence where Element: Encodable {
    /// Screen Time tokens come in a Set, whose order changes on every launch.
    /// Sorting by the encoded token gives the same order every time.
    func sortedByEncoding() -> [Element] {
        let encoder = JSONEncoder()
        return map { (element: $0, key: (try? encoder.encode($0)) ?? Data()) }
            .sorted { $0.key.lexicographicallyPrecedes($1.key) }
            .map(\.element)
    }
}
