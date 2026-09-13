//
//  Font+App.swift
//  StepFirst
//
//  Apple HIG Native Dynamic Type Tokens (Style + Weight)
//

import SwiftUI

extension Font {
    // MARK: - Large Title (34pt)
    static let largeTitleRegular: Font = .largeTitle
    static let largeTitleBold: Font = .largeTitle.weight(.bold)
    static let largeTitleRoundedBold: Font = .system(.largeTitle, design: .rounded).weight(.bold)

    // MARK: - Title 1 (28pt)
    static let titleRegular: Font = .title
    static let titleBold: Font = .title.weight(.bold)
    static let titleRoundedBold: Font = .system(.title, design: .rounded).weight(.bold)

    // MARK: - Title 2 (22pt)
    static let title2Regular: Font = .title2
    static let title2Bold: Font = .title2.weight(.bold)

    // MARK: - Title 3 (20pt)
    static let title3Regular: Font = .title3
    static let title3Semibold: Font = .title3.weight(.semibold)
    static let title3Bold: Font = .title3.weight(.bold)

    // MARK: - Headline (17pt, Semibold by default)
    static let headlineSemibold: Font = .headline.weight(.semibold)
    static let headlineBold: Font = .headline.weight(.bold)

    // MARK: - Body (17pt)
    static let bodyRegular: Font = .body
    static let bodySemibold: Font = .body.weight(.semibold)
    static let bodyBold: Font = .body.weight(.bold)

    // MARK: - Callout (16pt)
    static let calloutRegular: Font = .callout
    static let calloutSemibold: Font = .callout.weight(.semibold)

    // MARK: - Subhead (15pt)
    static let subheadlineRegular: Font = .subheadline
    static let subheadlineSemibold: Font = .subheadline.weight(.semibold)

    // MARK: - Footnote (13pt)
    static let footnoteRegular: Font = .footnote
    static let footnoteSemibold: Font = .footnote.weight(.semibold)
    static let footnoteBold: Font = .footnote.weight(.bold)

    // MARK: - Caption 1 (12pt)
    static let captionRegular: Font = .caption
    static let captionSemibold: Font = .caption.weight(.semibold)

    // MARK: - Caption 2 (11pt)
    static let caption2Regular: Font = .caption2
    static let caption2Semibold: Font = .caption2.weight(.semibold)
}
