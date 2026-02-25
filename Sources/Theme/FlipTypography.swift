import SwiftUI

extension Font {
    static func flipTitle() -> Font {
        .system(size: 36, weight: .black, design: .rounded)
    }

    static func flipScore() -> Font {
        .system(size: 28, weight: .bold, design: .rounded)
    }

    static func flipBody() -> Font {
        .system(size: 16, weight: .semibold, design: .rounded)
    }

    static func flipCaption() -> Font {
        .system(size: 13, weight: .medium, design: .rounded)
    }

    static func flipHeadline() -> Font {
        .system(size: 20, weight: .bold, design: .rounded)
    }
}
